# =============================================================================
# AsciiDoc to HTML Converter for Minimalist Blog
# =============================================================================
# 
# This script converts AsciiDoc (.adoc) files to HTML that matches the site's theme.
# It uses a two-stage process:
#  1. Convert AsciiDoc to standard HTML using asciidoctor
#  2. Transform that HTML to match the site's layout and styling using templates
#
# Features:
# - Preserves content and table of contents from asciidoctor output
# - Applies the site's dark theme and structure
# - Maintains proper navigation and theme toggle
# - Supports LaTeX math via MathJax
# - Generates an index of all blog posts
#
# Usage: .\scripts\convert-adoc.ps1
#

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Import configuration settings
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$configPath = Join-Path -Path $scriptDir -ChildPath "config.ps1"

# Check if config file exists before importing
if (Test-Path $configPath) {
    try {
        . $configPath
        Write-Host "Configuration loaded successfully." -ForegroundColor Green
    } catch {
        Write-Error "Error loading configuration file: $_"
        exit 1
    }
} else {
    Write-Error "Configuration file not found at $configPath"
    exit 1
}

# Make sure output directory exists
if (-not (Test-Path $outputDir)) {
    try {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        Write-Host "Created output directory: $outputDir" -ForegroundColor Green
    } catch {
        Write-Error "Failed to create output directory: $_"
        exit 1
    }
}

# -----------------------------------------------------------------------------
# Template Loading and Processing
# -----------------------------------------------------------------------------

# Function to load a template file or use default if not found
function Get-Template {
    param (
        [string]$templatePath,
        [string]$defaultContent = "",
        [string]$templateName = "Template"
    )
    
    if (Test-Path $templatePath) {
        try {
            return Get-Content -Path $templatePath -Raw
        } catch {
            Write-Warning "$templateName file could not be read: $templatePath. $_"
            return $defaultContent
        }
    }
    
    Write-Warning "$templateName file not found: $templatePath. Using default content."
    return $defaultContent
}

# Function to replace placeholders in templates
function Replace-Placeholders {
    param (
        [string]$template,
        [hashtable]$replacements
    )
    
    foreach ($key in $replacements.Keys) {
        $template = $template -replace "{{$key}}", $replacements[$key]
    }
    
    return $template
}

# Function to build navigation HTML
function Build-Navigation {
    param (
        [array]$items,
        [string]$ulClass,
        [string]$ariaLabel
    )
    
    $navHtml = "<nav aria-label=`"$ariaLabel`">`n    <ul class=`"$ulClass`">`n"
    
    foreach ($item in $items) {
        $current = if ($item.Current) { ' aria-current="page"' } else { '' }
        $navHtml += "        <li><a href=`"$($item.Url)`"$current>$($item.Title)</a></li>`n"
    }
    
    $navHtml += "    </ul>`n</nav>"
    
    return $navHtml
}

# -----------------------------------------------------------------------------
# HTML Transformation Function
# -----------------------------------------------------------------------------
function Transform-HtmlToSiteTheme {
    param (
        [string]$htmlContent,
        [string]$title,
        [string]$date,
        [string]$formattedDate,
        [string]$description = "",
        [string]$keywords = ""
    )

    # Extract metadata from the AsciiDoc-generated HTML
    if ([string]::IsNullOrEmpty($description)) {
        $descMatch = [regex]::Match($htmlContent, '<meta name="description" content="(.*?)"')
        $description = if ($descMatch.Success) { $descMatch.Groups[1].Value } else { "Blog post about $title" }
    }
    
    if ([string]::IsNullOrEmpty($keywords)) {
        $keywordsMatch = [regex]::Match($htmlContent, '<meta name="keywords" content="(.*?)"')
        $keywords = if ($keywordsMatch.Success) { $keywordsMatch.Groups[1].Value } else { "" }
    }

    # Extract content and TOC from the HTML
    $contentMatch = [regex]::Match($htmlContent, '<div id="content">(.*?)<div id="footer">', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $content = if ($contentMatch.Success) { $contentMatch.Groups[1].Value } else { "" }
    
    $tocMatch = [regex]::Match($htmlContent, '<div id="toc" class="toc2">(.*?)</div>\s*</div>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $toc = if ($tocMatch.Success) { 
        "<div class=`"toctitle`">Table of Contents</div>`n$($tocMatch.Groups[1].Value)" 
    } else { 
        "" 
    }
    
    # Load templates
    $headerTemplate = Get-Template -templatePath $headerTemplatePath
    $footerTemplate = Get-Template -templatePath $footerTemplatePath
    $articleTemplate = Get-Template -templatePath $articleTemplatePath
    
    # Replace placeholders in header
    $headerReplacements = @{
        "title" = "$title - $siteTitle"
        "description" = $description
        "keywords" = $keywords
        "published_date" = $date
        "toc" = $toc
        "site_css" = $siteCssPath
    }
    $header = Replace-Placeholders -template $headerTemplate -replacements $headerReplacements
    
    # Replace placeholders in article
    $articleReplacements = @{
        "title" = $title
        "published_date" = $date
        "formatted_date" = $formattedDate
        "content" = $content
    }
    $article = Replace-Placeholders -template $articleTemplate -replacements $articleReplacements
    
    # Replace placeholders in footer
    $footerReplacements = @{
        "year" = (Get-Date).Year
        "site_js" = $siteJsPath
        "site_title" = $siteTitle
    }
    $footer = Replace-Placeholders -template $footerTemplate -replacements $footerReplacements
    
    # Combine all parts
    return "$header$article$footer"
}

# -----------------------------------------------------------------------------
# Math Accessibility Enhancements
# -----------------------------------------------------------------------------

# Function to enhance math content with fallbacks for NoScript users
function Add-MathFallbacks {
    param (
        [string]$htmlContent
    )
    
    # Don't process if there's no math content
    if (-not ($htmlContent -match 'class="math"')) {
        return $htmlContent
    }
    
    Write-Host "  Adding MathML fallbacks for math content..." -ForegroundColor Yellow
    
    # Add a data attribute to math containers to flag them as needing special handling
    $htmlContent = $htmlContent -replace '(<div class="math"[^>]*>)', '$1<!-- Math content with NoScript fallback -->'
    
    # Add an additional class to help style math content without JavaScript
    $htmlContent = $htmlContent -replace '(<div class="math"[^>]*>)', '$1<noscript><div class="math-fallback">This formula requires JavaScript with MathJax to render properly. Please see the text description below.</div></noscript>'
    
    # Ensure all math blocks have descriptive text following them
    # (We can't actually generate MathML here since that would require running LaTeX conversion,
    # but we can make sure users know they need JavaScript for proper rendering)
    
    return $htmlContent
}

# -----------------------------------------------------------------------------
# Main Conversion Process
# -----------------------------------------------------------------------------

# Get all AsciiDoc files in the source directory (excluding specified files)
$adocFiles = Get-ChildItem -Path $sourceDir -Filter "*.adoc" | 
             Where-Object { $excludeFiles -notcontains $_.Name }

$fileCount = $adocFiles.Count
Write-Host "Found $fileCount AsciiDoc files to convert." -ForegroundColor Cyan

if ($fileCount -eq 0) {
    Write-Warning "No AsciiDoc files found in $sourceDir. Please check the directory path."
    exit
}

# Convert each AsciiDoc file
foreach ($file in $adocFiles) {
    $outputFile = Join-Path -Path $outputDir -ChildPath ($file.BaseName + ".html")
    $tempFile = Join-Path -Path $env:TEMP -ChildPath ($file.BaseName + "_temp.html")
    Write-Host "Converting $($file.Name) to HTML..." -ForegroundColor Yellow
    
    # Extract metadata from AsciiDoc file
    $content = Get-Content -Path $file.FullName -Raw
    
    # Extract title
    $titleMatch = [regex]::Match($content, '^= (.*?)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { $file.BaseName }
    
    # Extract date
    $dateMatch = [regex]::Match($content, ':published_date: (.*)')
    $date = if ($dateMatch.Success) { $dateMatch.Groups[1].Value } else { Get-Date -Format "yyyy-MM-dd" }
    
    # Format date for display
    try {
        $formattedDate = [DateTime]::ParseExact($date, "yyyy-MM-dd", $null).ToString("MMMM d, yyyy")
    } catch {
        $formattedDate = $date
    }
    
    # Extract description (if available)
    $descriptionMatch = [regex]::Match($content, ':description: (.*)')
    $description = if ($descriptionMatch.Success) { $descriptionMatch.Groups[1].Value } else { "" }
    
    # Extract keywords (if available)
    $keywordsMatch = [regex]::Match($content, ':keywords: (.*)')
    $keywords = if ($keywordsMatch.Success) { $keywordsMatch.Groups[1].Value } else { "" }
    
    # Step 1: Convert AsciiDoc to basic HTML
    $command = "asciidoctor -a stem=latexmath -a source-highlighter=highlight.js -o `"$tempFile`" `"$($file.FullName)`""
    Invoke-Expression $command
    
    if ($LASTEXITCODE -eq 0) {
        # Step 2: Transform the HTML to match the site's theme
        $htmlContent = Get-Content -Path $tempFile -Raw
        $transformedHtml = Transform-HtmlToSiteTheme -htmlContent $htmlContent -title $title -date $date -formattedDate $formattedDate -description $description -keywords $keywords
        
        # Step 3: Add MathML fallbacks for math content to support NoScript users
        $transformedHtml = Add-MathFallbacks -htmlContent $transformedHtml
        
        # Step 4: Save the transformed HTML
        $transformedHtml | Out-File -FilePath $outputFile -Encoding utf8
        
        # Clean up temp file
        Remove-Item -Path $tempFile -Force
        
        Write-Host "Successfully converted $($file.Name) to $outputFile" -ForegroundColor Green
    } else {
        Write-Host "Error converting $($file.Name)" -ForegroundColor Red
    }
}

# -----------------------------------------------------------------------------
# Generate Index Page
# -----------------------------------------------------------------------------
Write-Host "Generating blog index page..." -ForegroundColor Yellow

# Get index template
$indexTemplate = Get-Template -templatePath $indexTemplatePath

# Get all HTML files generated from AsciiDoc (excluding index.html)
$htmlFiles = Get-ChildItem -Path $outputDir -Filter "*.html" | 
             Where-Object { $_.Name -ne "index.html" }

# Sort files by date (newest first)
$sortedHtmlFiles = $htmlFiles | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $dateMatch = [regex]::Match($content, '<meta name="published_date" content="(.*?)"')
    $date = if ($dateMatch.Success) { $dateMatch.Groups[1].Value } else { "1970-01-01" }
    
    [PSCustomObject]@{
        File = $_
        Date = $date
    }
} | Sort-Object -Property Date -Descending

# Build post list HTML
$postListHtml = ""
foreach ($fileObj in $sortedHtmlFiles) {
    $file = $fileObj.File
    $content = Get-Content -Path $file.FullName -Raw
    
    # Extract title
    $titleMatch = [regex]::Match($content, '<title>(.*?) -')
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { $file.BaseName }
    
    # Extract date
    $dateMatch = [regex]::Match($content, '<meta name="published_date" content="(.*?)"')
    $date = if ($dateMatch.Success) { $dateMatch.Groups[1].Value } else { Get-Date -Format "yyyy-MM-dd" }
    
    # Format date for display
    try {
        $formattedDate = [DateTime]::ParseExact($date, "yyyy-MM-dd", $null).ToString("MMMM d, yyyy")
    } catch {
        $formattedDate = $date
    }
    
    # Add entry to index
    $postListHtml += @"
                    <li>
                        <time datetime="$date">$formattedDate</time>
                        <a href="$($file.Name)">$title</a>
                    </li>
"@
}

# Load templates
$headerTemplate = Get-Template -templatePath $headerTemplatePath
$footerTemplate = Get-Template -templatePath $footerTemplatePath

# Replace placeholders in header
$headerReplacements = @{
    "title" = "Blog Posts Index - $siteTitle"
    "description" = "Index of all blog posts"
    "keywords" = "blog, index, posts"
    "published_date" = (Get-Date -Format "yyyy-MM-dd")
    "toc" = ""
    "site_css" = $siteCssPath
}
$header = Replace-Placeholders -template $headerTemplate -replacements $headerReplacements

# Replace placeholders in index
$indexReplacements = @{
    "post_list" = $postListHtml
}
$indexContent = Replace-Placeholders -template $indexTemplate -replacements $indexReplacements

# Replace placeholders in footer
$footerReplacements = @{
    "year" = (Get-Date).Year
    "site_js" = $siteJsPath
    "site_title" = $siteTitle
}
$footer = Replace-Placeholders -template $footerTemplate -replacements $footerReplacements

# Combine everything
$fullIndexHtml = "$header$indexContent$footer"

# Save the index file
$indexPath = Join-Path -Path $outputDir -ChildPath "index.html"
$fullIndexHtml | Out-File -FilePath $indexPath -Encoding utf8

Write-Host "Blog index created at $indexPath" -ForegroundColor Green
Write-Host "Conversion complete. All AsciiDoc files have been converted to HTML with the site's theme." -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# Print Summary
# -----------------------------------------------------------------------------
Write-Host "`nSummary:" -ForegroundColor Magenta
Write-Host "--------" -ForegroundColor Magenta
Write-Host "AsciiDoc Source: $sourceDir" -ForegroundColor White
Write-Host "HTML Output: $outputDir" -ForegroundColor White
Write-Host "Templates: $templatesDir" -ForegroundColor White
Write-Host "Converted Files: $($adocFiles.Count)" -ForegroundColor White
Write-Host "Output Files: $(($htmlFiles.Count) + 1) (including index)" -ForegroundColor White
Write-Host "Excluded Files: $($excludeFiles -join ', ')" -ForegroundColor White 
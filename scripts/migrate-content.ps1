# =============================================================================
# Content Migration Script
# =============================================================================
# This script helps migrate content from the old AsciiDoc-based system to Jekyll
#

# Import the old configuration
. "$PSScriptRoot\config.ps1"

# Create necessary directories if they don't exist
$postsDir = Join-Path -Path $rootDir -ChildPath "_posts"
$projectsDir = Join-Path -Path $rootDir -ChildPath "_projects"

if (-not (Test-Path -Path $postsDir)) {
    New-Item -ItemType Directory -Path $postsDir | Out-Null
    Write-Host "Created directory: $postsDir"
}

if (-not (Test-Path -Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
    Write-Host "Created directory: $projectsDir"
}

# Function to convert AsciiDoc to Markdown
function Convert-AsciiDocToMarkdown {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )
    
    # Check if pandoc is installed
    try {
        $pandocVersion = pandoc --version
        Write-Host "Using Pandoc: $($pandocVersion[0])"
    }
    catch {
        Write-Error "Pandoc is not installed or not in PATH. Please install Pandoc: https://pandoc.org/installing.html"
        exit 1
    }
    
    # Convert using pandoc
    pandoc -f asciidoc -t markdown_github -o $OutputFile $InputFile
    
    # Read the converted file
    $content = Get-Content -Path $OutputFile -Raw
    
    # Extract metadata from AsciiDoc
    $adocContent = Get-Content -Path $InputFile -Raw
    $title = ""
    $date = ""
    $categories = @()
    $tags = @()
    
    # Extract title
    if ($adocContent -match "= (.+)") {
        $title = $matches[1]
    }
    
    # Extract date
    if ($adocContent -match ":published_date: (.+)") {
        $date = $matches[1]
    }
    else {
        $date = (Get-Date).ToString("yyyy-MM-dd")
    }
    
    # Extract keywords as tags
    if ($adocContent -match ":keywords: (.+)") {
        $keywords = $matches[1]
        $tags = $keywords -split "," | ForEach-Object { $_.Trim() }
    }
    
    # Create Jekyll front matter
    $frontMatter = @"
---
layout: post
title: "$title"
date: $date
categories: []
tags: [$($tags -join ", ")]
---

"@
    
    # Combine front matter with content
    $newContent = $frontMatter + $content
    
    # Write the final file
    Set-Content -Path $OutputFile -Value $newContent
    
    Write-Host "Converted: $InputFile -> $OutputFile"
}

# Function to process all AsciiDoc files
function Process-AsciiDocFiles {
    param (
        [string]$SourceDir,
        [string]$DestDir,
        [string]$Layout = "post"
    )
    
    # Get all AsciiDoc files
    $adocFiles = Get-ChildItem -Path $SourceDir -Filter "*.adoc"
    
    foreach ($file in $adocFiles) {
        # Skip template files
        if ($excludeFiles -contains $file.Name) {
            Write-Host "Skipping template file: $($file.Name)"
            continue
        }
        
        # Determine output filename
        $fileDate = ""
        $fileContent = Get-Content -Path $file.FullName -Raw
        
        if ($fileContent -match ":published_date: (.+)") {
            $fileDate = $matches[1]
        }
        else {
            $fileDate = (Get-Date).ToString("yyyy-MM-dd")
        }
        
        $baseName = $file.BaseName
        $outputFileName = "$fileDate-$baseName.md"
        $outputPath = Join-Path -Path $DestDir -ChildPath $outputFileName
        
        # Convert the file
        Convert-AsciiDocToMarkdown -InputFile $file.FullName -OutputFile $outputPath
    }
}

# Main execution
Write-Host "Starting content migration..."

# Process blog posts
Write-Host "Processing blog posts..."
Process-AsciiDocFiles -SourceDir $sourceDir -DestDir $postsDir

Write-Host "Migration complete!"
Write-Host "Next steps:"
Write-Host "1. Review the converted files in _posts/ and _projects/"
Write-Host "2. Run 'bundle exec jekyll serve' to preview your site"
Write-Host "3. Make any necessary adjustments to the converted content" 
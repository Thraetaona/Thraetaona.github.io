# =============================================================================
# Build Script for Minimalist Blog
# =============================================================================
# 
# This script builds the entire website:
# 1. Converts AsciiDoc content to HTML
# 2. Copies assets if needed
# 3. Validates the output
#
# Usage: .\scripts\build.ps1 [-Clean] [-Validate]
#
# Parameters:
#   -Clean       If specified, cleans the output directory before building
#   -Validate    If specified, validates the HTML output for common issues
#

param(
    [switch]$Clean,
    [switch]$Validate
)

# -----------------------------------------------------------------------------
# Configuration and Setup
# -----------------------------------------------------------------------------
$ErrorActionPreference = "Stop"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$configPath = Join-Path -Path $scriptDir -ChildPath "config.ps1"
$convertPath = Join-Path -Path $scriptDir -ChildPath "convert-adoc.ps1"

# Load configuration
try {
    . $configPath
    Write-Host "Configuration loaded successfully." -ForegroundColor Green
} catch {
    Write-Error "Error loading configuration file: $_"
    exit 1
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Function to display script progress with color
function Write-Step {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    
    Write-Host ""
    Write-Host "===> $Message" -ForegroundColor $Color
    Write-Host ""
}

# Function to clean output directory
function Clean-OutputDirectory {
    param (
        [string]$Directory
    )
    
    if (Test-Path $Directory) {
        Write-Step "Cleaning output directory: $Directory"
        try {
            Get-ChildItem -Path $Directory -File | Remove-Item -Force
            Get-ChildItem -Path $Directory -Directory | Remove-Item -Recurse -Force
            Write-Host "Output directory cleaned successfully." -ForegroundColor Green
        } catch {
            Write-Error "Failed to clean output directory: $_"
            exit 1
        }
    }
}

# Function to validate HTML output
function Validate-HtmlOutput {
    param (
        [string]$Directory
    )
    
    Write-Step "Validating HTML output"
    
    $htmlFiles = Get-ChildItem -Path $Directory -Filter "*.html" -Recurse
    
    if ($htmlFiles.Count -eq 0) {
        Write-Warning "No HTML files found for validation."
        return
    }
    
    Write-Host "Found $($htmlFiles.Count) HTML files to validate." -ForegroundColor Yellow
    
    # Simple validation for common issues
    $issues = @()
    
    foreach ($file in $htmlFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check for basic HTML structure issues
        if (-not ($content -match "<html.*>")) {
            $issues += "Missing <html> tag in $($file.Name)"
        }
        
        if (-not ($content -match "<head>.*</head>")) {
            $issues += "Missing <head> section in $($file.Name)"
        }
        
        if (-not ($content -match "<body>.*</body>")) {
            $issues += "Missing <body> section in $($file.Name)"
        }
        
        # Check for broken links (relative paths that don't exist)
        $links = [regex]::Matches($content, 'href="([^"#]+)"')
        foreach ($link in $links) {
            $href = $link.Groups[1].Value
            
            # Skip absolute URLs
            if ($href -match "^(https?:|mailto:|tel:)") {
                continue
            }
            
            # Check if the linked file exists
            $linkPath = [System.IO.Path]::Combine($file.DirectoryName, $href)
            $normalizedPath = [System.IO.Path]::GetFullPath($linkPath)
            
            if (-not (Test-Path $normalizedPath)) {
                $issues += "Broken link in $($file.Name): $href"
            }
        }
        
        # Check for common accessibility issues
        if ($content -match "<img[^>]*(?!alt=)[^>]*>") {
            $issues += "Image without alt attribute in $($file.Name)"
        }
    }
    
    # Report issues
    if ($issues.Count -gt 0) {
        Write-Warning "Found $($issues.Count) issues:"
        foreach ($issue in $issues) {
            Write-Host " - $issue" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Validation completed. No issues found." -ForegroundColor Green
    }
}

# -----------------------------------------------------------------------------
# Main Build Process
# -----------------------------------------------------------------------------

# Display build info
Write-Step "Building Minimalist Blog website" "Magenta"
Write-Host "Build started at: $(Get-Date)"

# Clean if requested
if ($Clean) {
    Clean-OutputDirectory $assetsDir
}

# Convert AsciiDoc content to HTML
Write-Step "Converting AsciiDoc content to HTML"
try {
    & $convertPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "AsciiDoc conversion failed with exit code $LASTEXITCODE"
        exit 1
    }
    
    Write-Host "AsciiDoc conversion completed successfully." -ForegroundColor Green
} catch {
    Write-Error "AsciiDoc conversion failed: $_"
    exit 1
}

# Validate if requested
if ($Validate) {
    Validate-HtmlOutput $assetsDir
}

# Build completion
Write-Step "Build completed successfully!" "Green"
Write-Host "Build finished at: $(Get-Date)"
Write-Host "Output directory: $assetsDir"
Write-Host ""
Write-Host "To view the site locally, navigate to the public directory and start a web server."
Write-Host "For example, using Python: python -m http.server --directory $assetsDir" 
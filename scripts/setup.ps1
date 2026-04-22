# =============================================================================
# Jekyll Setup Script
# =============================================================================
# This script helps set up and run the Jekyll site

# Ensure fonts directory exists
$fontsDir = Join-Path -Path $PSScriptRoot -ChildPath "..\assets\fonts\serifa"
if (-not (Test-Path -Path $fontsDir)) {
    New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
    Write-Host "Created fonts directory: $fontsDir"
    
    # Copy fonts from the old site if they exist
    $oldFontsDir = Join-Path -Path $PSScriptRoot -ChildPath "..\public\fonts\serifa"
    if (Test-Path -Path $oldFontsDir) {
        Copy-Item -Path "$oldFontsDir\*" -Destination $fontsDir -Force
        Write-Host "Copied font files from old location"
    } else {
        Write-Host "Please copy your Serifa font files to: $fontsDir"
    }
}

# Check if Ruby is installed
try {
    $rubyVersion = ruby -v
    Write-Host "Ruby is installed: $rubyVersion"
}
catch {
    Write-Host "Ruby is not installed or not in PATH. Please install Ruby: https://rubyinstaller.org/"
    Write-Host "Be sure to select 'Add Ruby executables to your PATH' and 'Associate .rb and .rbw files with Ruby installation' during installation."
    Write-Host "IMPORTANT: Choose the option WITH DevKit during installation (usually the second or third option in the installer)."
    exit 1
}

# Check if Ruby DevKit is installed
$devkitInstalled = $false
try {
    # Try to run gcc which is part of DevKit
    $devKitInfo = gcc --version
    $devkitInstalled = $true
    Write-Host "Ruby DevKit is installed"
} catch {
    Write-Host "WARNING: Ruby DevKit appears to be missing. Some gems requiring native extensions may fail to install."
    Write-Host "If you encounter installation errors, please reinstall Ruby using the option WITH DevKit."
    Write-Host "Typically, select the MSYS2 option during installation (Ruby+Devkit)."
    $devkitInstalled = $false
}

# Check if Bundler is installed
try {
    $bundlerVersion = bundle -v
    Write-Host "Bundler is installed: $bundlerVersion"
}
catch {
    Write-Host "Installing Bundler..."
    gem install bundler
}

# Install dependencies
Write-Host "Installing Jekyll and dependencies..."
Write-Host "NOTE: Some optional dependencies may fail to install if DevKit is missing. This is normal and the site will still work."
bundle install

# Notify about potential wdm issues
if (-not $devkitInstalled) {
    Write-Host "`nNotice: The 'wdm' gem might not have installed correctly because DevKit is missing." -ForegroundColor Yellow
    Write-Host "This gem is only needed for improved file watching on Windows and is not required for basic functionality." -ForegroundColor Yellow
    Write-Host "You can safely ignore errors related to wdm installation.`n" -ForegroundColor Yellow
}

# Build the site
Write-Host "Building the site..."
bundle exec jekyll build

# Run the site
Write-Host "Starting the Jekyll server..."
Write-Host "Open your browser and navigate to: http://localhost:4000"
bundle exec jekyll serve 
# =============================================================================
# Jekyll Quick Start Script
# =============================================================================
# This is a simplified script to get Jekyll running without native extension dependencies

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
    Write-Host "Any version will work for this quick start."
    exit 1
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

# Create a temporary Gemfile without native extensions
$tempGemfile = @"
source "https://rubygems.org"

# Jekyll and plugins
gem "jekyll", "~> 4.3.2"
gem "jekyll-paginate"
gem "jekyll-feed"
gem "jekyll-sitemap"
gem "webrick", "~> 1.8"

# Windows and JRuby does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
"@

$tempGemfilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\Gemfile.tmp"
Set-Content -Path $tempGemfilePath -Value $tempGemfile

# Install only the essential dependencies
Write-Host "Installing Jekyll and essential plugins (skipping native extensions)..."
$env:BUNDLE_GEMFILE = $tempGemfilePath
bundle install

# Run the site using the temporary Gemfile
Write-Host "Starting the Jekyll server (in watch mode, without live reload)..."
Write-Host "Open your browser and navigate to: http://localhost:4000"
bundle exec jekyll serve --watch --no-livereload

# Cleanup - remove temp Gemfile when finished
# Note: This won't execute until the server is stopped
Remove-Item -Path $tempGemfilePath -Force 
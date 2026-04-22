# =============================================================================
# Site Configuration
# =============================================================================
# This file contains all the configuration settings for the website build process.
# It is imported by the conversion and build scripts.
#

# -----------------------------------------------------------------------------
# Site Information
# -----------------------------------------------------------------------------
$siteTitle = "Bitwise"
$siteDescription = "A minimalist, accessible blog showcasing projects and thoughts on technology."
$siteAuthor = "Website Author"
$siteYear = (Get-Date).Year

# -----------------------------------------------------------------------------
# Directory Paths
# -----------------------------------------------------------------------------
# Define the root directory (relative to the script location)
$rootDir = (Get-Item -Path $PSScriptRoot).Parent.FullName

# Source content directories
$sourceDir = Join-Path -Path $rootDir -ChildPath "content\blog"    # AsciiDoc source files
$templatesDir = Join-Path -Path $rootDir -ChildPath "templates"    # Template files

# Output directories
$outputDir = Join-Path -Path $rootDir -ChildPath "public\blog"     # Blog output HTML files
$assetsDir = Join-Path -Path $rootDir -ChildPath "public"          # Assets directory (CSS, JS)

# -----------------------------------------------------------------------------
# File Paths
# -----------------------------------------------------------------------------
# Template file paths
$headerTemplatePath = Join-Path -Path $templatesDir -ChildPath "header.html"
$footerTemplatePath = Join-Path -Path $templatesDir -ChildPath "footer.html"
$articleTemplatePath = Join-Path -Path $templatesDir -ChildPath "article.html"
$indexTemplatePath = Join-Path -Path $templatesDir -ChildPath "index.html"

# Asset paths (relative to blog directory for use in templates)
$siteCssPath = "../styles.css"  # Relative to the blog directory
$siteJsPath = "../script.js"    # Relative to the blog directory

# -----------------------------------------------------------------------------
# Build Configuration
# -----------------------------------------------------------------------------
# Files to exclude from processing
$excludeFiles = @("template.adoc")

# Navigation configuration
$navItems = @(
    @{ Title = "Home"; Url = "../index.html" },
    @{ Title = "Blog"; Url = "../blog.html"; Current = $true },
    @{ Title = "Projects"; Url = "../projects.html" },
    @{ Title = "About"; Url = "../about.html" }
)

# -----------------------------------------------------------------------------
# AsciiDoc Configuration
# -----------------------------------------------------------------------------
# AsciiDoc attributes
$asciidocAttributes = @(
    "stem=latexmath",
    "source-highlighter=highlight.js",
    "icons=font"
)

# -----------------------------------------------------------------------------
# Content Processing Options
# -----------------------------------------------------------------------------
# Date format settings
$dateInputFormat = "yyyy-MM-dd"
$dateOutputFormat = "MMMM d, yyyy"

# Enable/disable features
$enableTOC = $true
$enableMathJax = $true 
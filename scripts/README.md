# Scripts Directory

This directory contains scripts for managing and building the website.

## Available Scripts

- **convert-adoc.ps1**: Converts AsciiDoc files to HTML with the site's theme

## convert-adoc.ps1

This script converts AsciiDoc (.adoc) files to HTML that matches the site's theme.

### Features

- Converts all AsciiDoc files in the `content/blog/` directory
- Applies the site's theme and structure using templates
- Maintains proper navigation and theme toggle
- Supports LaTeX math via MathJax
- Generates an index of all blog posts
- Outputs HTML to the `public/blog/` directory

### Usage

```powershell
.\scripts\convert-adoc.ps1
```

### Process

The script:
1. Scans the `content/blog/` directory for AsciiDoc files
2. Extracts metadata (title, date, description, etc.) from each file
3. Converts AsciiDoc to basic HTML using Asciidoctor
4. Transforms that HTML to match the site's theme using templates
5. Generates an index page of all blog posts
6. Outputs everything to the `public/blog/` directory

### Requirements

- PowerShell 5.0 or higher
- Asciidoctor gem installed (`gem install asciidoctor`)

### Configuration

You can modify these variables in the script:

- `$sourceDir`: Directory containing AsciiDoc files
- `$outputDir`: Output directory for HTML files
- `$templatesDir`: Directory containing HTML templates
- `$excludeFiles`: Files to exclude from conversion
- `$siteTitle`: Title of the website
- `$siteCssPath`: Path to the CSS file
- `$siteJsPath`: Path to the JavaScript file
- `$navItems`: Navigation items configuration

### Customizing

To customize the script:

1. Edit the script directly to change paths, configurations, or functionality
2. Modify the templates in the `templates/` directory for changes to HTML structure
3. Update CSS in the `public/styles.css` file for styling changes

### Output

The script generates:
- HTML files for each AsciiDoc file
- An index.html file listing all blog posts sorted by date
- Console output showing the conversion process 
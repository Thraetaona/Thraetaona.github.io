# Minimalist Blog Usage Guide

This document provides detailed instructions for using, customizing, and maintaining the Minimalist Blog.

## Table of Contents

- [Getting Started](#getting-started)
- [Creating Content](#creating-content)
- [Building the Site](#building-the-site)
- [Customizing the Site](#customizing-the-site)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Prerequisites

- Windows with PowerShell (for build scripts)
- [Asciidoctor](https://asciidoctor.org/) installed for AsciiDoc conversion
- [Ruby](https://www.ruby-lang.org/) (required for Asciidoctor)

### Installation

1. Clone or download this repository
2. Install the required dependencies:

```powershell
# Install Ruby if not already installed
# Download from https://rubyinstaller.org/

# Install Asciidoctor
gem install asciidoctor
```

## Creating Content

### Writing Blog Posts

1. Navigate to the `content/blog` directory
2. Copy the `template.adoc` file to create a new blog post
3. Rename it to something descriptive, e.g., `my-first-post.adoc`
4. Edit the metadata at the top of the file:

```asciidoc
= Your Post Title
:stem: latexmath
:toc: left
:icons: font
:doctype: article
:description: A brief description for metadata and SEO.
:keywords: keyword1, keyword2, keyword3
:published_date: YYYY-MM-DD
```

5. Write your content using AsciiDoc syntax
6. Save the file

### AsciiDoc Syntax Guide

See the [AsciiDoc Syntax Quick Reference](https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/) for comprehensive documentation.

Common elements:

- **Headers**: `= Level 1`, `== Level 2`, `=== Level 3`
- **Bold**: `*bold text*`
- **Italic**: `_italic text_`
- **Links**: `https://example.com[Link Text]`
- **Lists**: 
  ```asciidoc
  * Unordered item
  * Another item
  
  . Ordered item
  . Another item
  ```
- **Code blocks**:
  ```asciidoc
  [source,javascript]
  ----
  console.log("Hello World");
  ----
  ```
- **Math expressions**:
  ```asciidoc
  [stem]
  ++++
  E = mc^2
  ++++
  ```

## Building the Site

### Full Build

To perform a complete build of the site:

```powershell
.\scripts\build.ps1
```

This will:
1. Convert all AsciiDoc files to HTML
2. Apply templates and styling
3. Generate an index of all posts

### Options

- **Clean build**: `.\scripts\build.ps1 -Clean`
- **Build with validation**: `.\scripts\build.ps1 -Validate`
- **Both options**: `.\scripts\build.ps1 -Clean -Validate`

### Converting AsciiDoc Only

If you only want to convert AsciiDoc files without a full build:

```powershell
.\scripts\convert-adoc.ps1
```

## Customizing the Site

### Modifying Templates

Templates are located in the `templates` directory:

- `header.html` - Site header and beginning HTML
- `footer.html` - Site footer and closing HTML
- `article.html` - Template for individual blog posts
- `index.html` - Template for the blog index page

### Changing Styles

The site's styles are defined in `public/styles.css`.

Key sections:

- **Theme variables**: At the top, defining colors for light and dark themes
- **Layout styles**: Container, header, footer settings
- **Typography**: Font sizes, line heights, etc.
- **Components**: Navigation, buttons, code blocks, etc.

### Site Configuration

Site-wide settings are in `scripts/config.ps1`:

- Site title, description, author
- Directory paths
- Navigation structure
- Build options

## Deployment

### Local Testing

To test the site locally:

```powershell
# Navigate to the public directory
cd public

# Start a simple web server (if Python is installed)
python -m http.server

# Or use any other local web server
```

### Hosting Options

The site can be deployed to:

1. **GitHub Pages**: Push the `public` directory to a GitHub repository and enable GitHub Pages
2. **Netlify/Vercel**: Set the `public` directory as the publish directory
3. **Traditional web hosting**: Upload the `public` directory to your web host

## Troubleshooting

### Common Issues

1. **AsciiDoc conversion fails**:
   - Ensure Asciidoctor is installed: `asciidoctor --version`
   - Check for syntax errors in your AsciiDoc files

2. **Broken links in the generated site**:
   - Run the build with validation: `.\scripts\build.ps1 -Validate`
   - Check relative paths in your content

3. **Styling issues**:
   - Inspect the generated HTML to ensure classes are correctly applied
   - Check browser console for CSS errors

### Getting Help

If you encounter issues not covered here, please:

1. Check the README file for additional information
2. Consult the [AsciiDoctor documentation](https://docs.asciidoctor.org/)
3. Create an issue in the project repository 
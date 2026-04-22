# HTML Templates for Minimalist Blog

This directory contains the HTML templates used by the AsciiDoc conversion script to generate the blog pages.

## Available Templates

- **header.html**: The header section of all pages, including `<head>` content and top navigation
- **footer.html**: The footer section of all pages, including copyright and bottom navigation
- **article.html**: The article content template for individual blog posts
- **index.html**: The template for the blog index page that lists all posts

## Template Variables

Templates use a simple {{variable}} syntax for placeholders. Here are the variables you can use:

### Header Template
- `{{title}}`: Page title
- `{{description}}`: Meta description
- `{{keywords}}`: Meta keywords
- `{{published_date}}`: Publication date (format: YYYY-MM-DD)
- `{{site_css}}`: Path to the CSS file
- `{{toc}}`: Table of contents HTML

### Article Template
- `{{title}}`: Article title
- `{{published_date}}`: Publication date (YYYY-MM-DD)
- `{{formatted_date}}`: Formatted date (e.g., "March 7, 2023")
- `{{content}}`: The main article content

### Footer Template
- `{{year}}`: Current year for copyright
- `{{site_js}}`: Path to the JavaScript file
- `{{site_title}}`: Site title

### Index Template
- `{{post_list}}`: HTML list of blog posts

## Customizing Templates

1. Edit the template files directly to modify the HTML structure
2. Add new placeholders to the templates if needed
3. Update the conversion script to pass the new variables to the templates

The conversion script uses these templates by:
1. Loading the template files
2. Extracting data from the AsciiDoc content
3. Replacing the placeholders with actual values
4. Combining the templates to create the final HTML

Remember to test your changes by running the conversion script after modifying templates. 
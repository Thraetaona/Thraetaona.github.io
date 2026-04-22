# Content Directory

This directory contains the source content for the website, organized by type.

## Structure

- `blog/`: AsciiDoc (.adoc) files for blog posts
- Add other content directories as needed (e.g., `projects/`, `pages/`)

## Creating Blog Posts

1. Create a new AsciiDoc file in the `blog/` directory
2. Start with the proper metadata header
3. Add your content using AsciiDoc syntax
4. Run the conversion script to generate HTML

### AsciiDoc Blog Post Template

```asciidoc
= Title of Your Blog Post
:stem: latexmath
:toc: left
:icons: font
:doctype: article
:description: A brief description for metadata and SEO.
:keywords: keyword1, keyword2, keyword3
:published_date: YYYY-MM-DD

== Introduction

Your introduction paragraph here.

== Main Content

Your main content here.

=== Subsection

Subsection content goes here.

== Conclusion

Your conclusion paragraph here.
```

### AsciiDoc Features

- Headers with `=`, `==`, `===`
- Lists with `*` for bullets, `.` for numbered
- Code blocks with `[source,language]` and `----` delimiters
- Links with `link:url[text]`
- Images with `image::path[alt]`
- Math with `stem:[inline math]` or `[stem]` blocks
- Admonitions with `[NOTE]`, `[TIP]`, `[WARNING]`
- Tables with `|===` syntax

### Converting Content

After creating or editing AsciiDoc files, run the conversion script:

```powershell
.\scripts\convert-adoc.ps1
```

This will:
1. Convert all AsciiDoc files to HTML
2. Apply the site's theme and styling
3. Generate an index page of all posts
4. Place the output in the `/public/blog/` directory

## Content Guidelines

- Use meaningful filenames (e.g., `meaningful-post-title.adoc`)
- Include all required metadata
- Set a proper publication date
- Add descriptive alt text for images
- Organize content with proper heading hierarchy
- Use AsciiDoc features for better readability 
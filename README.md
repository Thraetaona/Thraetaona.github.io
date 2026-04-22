# Bitwise - Jekyll Blog

A minimalist, accessible blog showcasing projects and thoughts on technology, built with Jekyll.

## Features

- **Light and Dark Theme**: Seamless theme switching with persistent preferences
- **Responsive Design**: Optimized for all screen sizes
- **Accessibility Focused**: WCAG compliant with high contrast and proper semantic markup
- **Custom Typography**: Uses the Serifa font family for elegant typography
- **Math Support**: MathJax integration for beautiful mathematical equations
- **Code Highlighting**: Syntax highlighting for code blocks
- **Project Showcase**: Dedicated project collection to showcase your work

## Getting Started

### Prerequisites

- Ruby (version 2.5.0 or higher)
- RubyGems
- GCC and Make

### Installation

1. Clone this repository
   ```
   git clone https://github.com/yourusername/bitwise.git
   cd bitwise
   ```

2. Install dependencies
   ```
   bundle install
   ```

3. Run the development server
   ```
   bundle exec jekyll serve
   ```

4. Open your browser and navigate to `http://localhost:4000`

## Customization

### Site Configuration

Edit `_config.yml` to customize your site settings:

- Site title, description, and author information
- Build settings and plugins
- Collection configurations

### Content Management

- **Blog Posts**: Add Markdown files to the `_posts` directory
- **Projects**: Add Markdown files to the `_projects` directory
- **Pages**: Edit or add HTML/Markdown files in the root directory

### Styling

- **Variables**: Edit `_sass/_variables.scss` to customize colors and typography
- **Components**: Modify component styles in `_sass/_components.scss`
- **Layout**: Adjust layout styles in `_sass/_layout.scss`

## Deployment

This site can be deployed to any static site hosting service:

- GitHub Pages
- Netlify
- Vercel
- AWS S3
- And more

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Jekyll for the static site generation
- Original design and implementation by [Your Name] 
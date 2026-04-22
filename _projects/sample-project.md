---
layout: project
title: "Sample Project"
project_status: Active
priority: 1
github_url: https://github.com/username/sample-project
demo_url: https://example.com/demo
technologies:
  - JavaScript
  - HTML5
  - CSS3
  - Jekyll
---

This is a sample project to demonstrate the project layout and functionality. You can add detailed descriptions, images, and other content here.

## Features

- Responsive design
- Light and dark theme support
- Accessibility focused
- Fast loading times

## Implementation Details

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget felis eget urna ultricies fermentum. Cras aliquet, nisl ut semper elementum, nunc nisl aliquam nisl, eget aliquam nisl nisl sit amet nisl.

```javascript
// Sample code
function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  
  html.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);
}
```

## Future Plans

- Add more features
- Improve performance
- Expand documentation 
/**
 * Minimalist Blog JavaScript
 * --------------------------
 * PROGRESSIVE ENHANCEMENT ONLY
 * 
 * This script provides enhancements but is NOT required for core functionality.
 * The site should work perfectly fine with JavaScript disabled.
 */

/**
 * Theme Management
 * Handles syncing the CSS-only theme toggle with localStorage
 * and HTML data attributes for persistence
 */
const ThemeManager = {
    // DOM elements
    elements: {
        html: document.documentElement,
        toggleCheckbox: null
    },
    
    // Theme values
    themes: {
        dark: 'dark',
        light: 'light'
    },
    
    // Storage key
    storageKey: 'theme',
    
    /**
     * Initialize theme functionality
     */
    init: function() {
        // Get the toggle checkbox (used by the CSS-only solution)
        this.elements.toggleCheckbox = document.getElementById('themeToggleCheckbox');
        if (!this.elements.toggleCheckbox) return;
        
        // Apply saved theme if exists
        this.loadSavedTheme();
        
        // Set up event listener to save preference when toggle changes
        this.elements.toggleCheckbox.addEventListener('change', this.handleToggleChange.bind(this));
    },
    
    /**
     * Load saved theme preference from localStorage
     */
    loadSavedTheme: function() {
        const savedTheme = localStorage.getItem(this.storageKey);
        
        if (savedTheme) {
            // Apply the saved theme using the CSS approach
            if (savedTheme === this.themes.light) {
                this.elements.toggleCheckbox.checked = true;
            } else {
                this.elements.toggleCheckbox.checked = false;
            }
            
            // Also update HTML attribute for completeness
            this.elements.html.setAttribute('data-theme', savedTheme);
        }
    },
    
    /**
     * Handle theme toggle changes
     */
    handleToggleChange: function() {
        const newTheme = this.elements.toggleCheckbox.checked ? 
            this.themes.light : this.themes.dark;
        
        // Update HTML attribute (which CSS will apply as well)
        this.elements.html.setAttribute('data-theme', newTheme);
        
        // Save the preference
        this.saveTheme(newTheme);
    },
    
    /**
     * Save theme preference to localStorage
     * @param {string} theme - The theme to save
     */
    saveTheme: function(theme) {
        localStorage.setItem(this.storageKey, theme);
    }
};

/**
 * Accessibility Enhancements
 * Improves accessibility of various elements
 */
const AccessibilityEnhancements = {
    /**
     * Initialize accessibility enhancements
     */
    init: function() {
        this.makeCodeBlocksKeyboardAccessible();
    },
    
    /**
     * Make code blocks with horizontal scroll focusable for keyboard navigation
     * (CSS-only version of this is also implemented so this is just an enhancement)
     */
    makeCodeBlocksKeyboardAccessible: function() {
        const codeBlocks = document.querySelectorAll('pre');
        
        codeBlocks.forEach(block => {
            // Only make focusable if content overflows
            if (block.scrollWidth > block.clientWidth) {
                block.tabIndex = 0;
            }
        });
    }
};

/**
 * MathJax Loading
 * Loads MathJax library when mathematical content is present
 * Note: A fallback for NoScript users is provided in the HTML
 */
const MathSupport = {
    /**
     * Check if math content exists and load MathJax if needed
     */
    init: function() {
        // MathJax is loaded via the header template
        // This just ensures it's configured properly when needed
        if (document.querySelector('.math') && window.MathJax) {
            // MathJax is already loaded, just ensure it's typeset
            if (typeof window.MathJax.typeset === 'function') {
                window.MathJax.typeset();
            }
        }
    }
};

/**
 * Initialize all functionality when the DOM is ready
 * These are all ENHANCEMENTS, not requirements
 */
document.addEventListener('DOMContentLoaded', function() {
    // Initialize theme functionality
    ThemeManager.init();
    
    // Initialize accessibility enhancements
    AccessibilityEnhancements.init();
    
    // Initialize math support
    MathSupport.init();
}); 
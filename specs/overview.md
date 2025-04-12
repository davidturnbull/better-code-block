# better-code-block - Overview

## Purpose

The better-code-block plugin enhances Vim/Neovim's Markdown editing experience by providing a powerful way to highlight specific lines within fenced code blocks. This functionality is particularly valuable for:

- **Technical documentation writers** who need to draw attention to specific parts of code examples
- **Educators** creating tutorials where certain lines need emphasis
- **Developers** writing READMEs or documentation with annotated code examples
- **Content creators** producing technical blog posts or presentations

The plugin serves as a bridge between plain Markdown and more sophisticated documentation systems, allowing users to create visually enhanced code examples without leaving their Vim environment or requiring external processing tools.

## Core Functionality

At its core, the plugin:

1. **Detects fenced code blocks** in Markdown and other supported markup files
2. **Parses highlight specifications** from the opening fence line (e.g., ```python highlight="1,3,5-7")
3. **Applies visual highlighting** to the specified lines within the code block
4. **Optionally adds line numbers** to improve readability and reference

## Key Features

### Line Highlighting

- **Flexible syntax** for specifying lines to highlight:

  - Single lines: `highlight="3"`
  - Multiple lines: `highlight="1,3,5"`
  - Line ranges: `highlight="1-3"`
  - Mixed formats: `highlight="1-3,5,7-9"`
  - Alternative separator: `highlight="1-3:5"` (equivalent to `1-3,5`)

- **Multiple keyword support** for triggering highlighting:
  - Primary: `highlight=`
  - Aliases: `hl=`, `mark=`, `emphasize=`

### Visual Customization

- **Multiple built-in styles** including:

  - Color-based: green, blue, yellow, cyan, magenta
  - Attribute-based: bold, italic, underline, undercurl, invert

- **Custom style registration** allowing users to define their own highlight styles with:
  - Terminal colors (cterm attributes)
  - GUI colors (gui attributes)
  - Combined attributes for maximum compatibility

### Line Numbering

- **Relative line numbers** within code blocks for easy reference
- **Multiple implementation methods** for compatibility:
  - Neovim virtual text (modern Neovim)
  - Text properties (modern Vim)
  - Sign column (legacy Vim)

### Language Support

- **Automatic language detection** from fence specification
- **Syntax highlighting integration** with Vim's built-in language support
- **Support for common language identifiers** and their aliases

### User Experience

- **Automatic activation** for supported file types
- **Toggle functionality** to enable/disable highlighting
- **Commands for controlling behavior** at runtime
- **Configurable through global variables** in user's vimrc

## Design Philosophy

The plugin follows several key design principles:

1. **Non-intrusive integration** with Vim's existing Markdown support
2. **Maximum compatibility** across different Vim versions and distributions
3. **Graceful degradation** when advanced features aren't available
4. **Sensible defaults** with extensive customization options
5. **Performance consciousness** even with large documents

By enhancing code blocks with visual highlighting, the plugin significantly improves the readability and pedagogical value of technical documentation created within Vim.

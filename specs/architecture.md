# better-code-blocks - Architecture

This document outlines the architectural design of the better-code-blocks plugin, explaining how its components interact to provide enhanced code block highlighting in Markdown files.

## Directory Structure

The plugin follows a standard Vim plugin structure:

```
better-code-blocks/
├── autoload/
│   └── better_code_blocks.vim    # Core functionality implementation
├── plugin/
│   └── better_code_blocks.vim    # Plugin initialization and configuration
├── ftplugin/
│   └── markdown/
│       └── better_code_blocks.vim # Filetype-specific integration
├── syntax/
│   └── markdown_better_code_blocks_languages.vim # Language support
├── test/
│   ├── highlighting.vader       # Tests for highlighting functionality
│   └── minimal_vimrc            # Minimal configuration for tests
├── doc/
│   └── better-code-blocks.txt    # Help documentation
└── README.md                    # User documentation
```

## Component Overview

The plugin is organized into several logical components, each with specific responsibilities:

### 1. Configuration System

**Location:** `plugin/better_code_blocks.vim`

The configuration system:

- Defines default values for all plugin settings
- Provides global variables for user customization
- Sets up commands for runtime control
- Initializes the plugin environment

Key configuration variables include:

- `g:better_code_blocks_style` - Default highlight style
- `g:better_code_blocks_extensions` - File types to activate on
- `g:better_code_blocks_keyword` and `g:better_code_blocks_keyword_aliases` - Keywords for highlighting
- `g:better_code_blocks_show_line_numbers` - Line number display toggle
- `g:better_code_blocks_line_number_method` - Method for displaying line numbers

### 2. Core Highlighting System

**Location:** `autoload/better_code_blocks.vim`

The core highlighting system:

- Scans buffers for fenced code blocks
- Parses highlight specifications
- Applies visual highlighting to specified lines
- Manages line numbering display
- Handles cleanup and error conditions

Key functions include:

- `better_code_blocks#apply_highlighting()` - Main entry point for highlighting
- `better_code_blocks#parse_highlight_spec()` - Extracts highlight specifications
- `better_code_blocks#parse_highlight_attribute()` - Parses line specifications
- `s:find_code_blocks()` - Locates code blocks in the buffer
- `s:highlight_line()` - Applies highlighting to a specific line

### 3. Language Support System

**Location:** `syntax/markdown_better_code_blocks_languages.vim`

The language support system:

- Maps language identifiers to Vim syntax files
- Loads appropriate syntax highlighting for code blocks
- Integrates with Vim's syntax highlighting system

Key components:

- `s:supported_languages` dictionary - Maps language aliases to syntax files
- `s:load_syntax_for()` - Loads syntax for a specific language
- `better_code_blocks#load_all_syntaxes()` - Initializes all language support

### 4. Filetype Integration

**Location:** `ftplugin/markdown/better_code_blocks.vim`

The filetype integration:

- Activates the plugin for specific file types
- Sets up buffer-local mappings and variables
- Manages buffer-specific autocommands
- Handles cleanup when leaving buffers

### 5. Testing Framework

**Location:** `test/`

The testing framework:

- Provides comprehensive tests for plugin functionality
- Uses Vader.vim for test execution
- Includes test cases for all major features

## Data Flow

The plugin's data flow follows this sequence:

1. **Initialization**:

   - Plugin loads when Vim starts
   - Default configuration is established
   - Commands and autocommands are registered

2. **Activation**:

   - When a supported file type is opened, the ftplugin is loaded
   - Buffer-local settings are initialized
   - Initial highlighting is applied

3. **Highlighting Process**:

   - Buffer is scanned for fenced code blocks
   - Each code block's fence line is parsed for highlight specifications
   - Highlight specifications are converted to line numbers
   - Visual highlighting is applied to specified lines
   - Line numbers are added if enabled

4. **User Interaction**:

   - User can toggle highlighting on/off
   - User can change highlight styles
   - User can toggle line numbers
   - User can register custom styles

5. **Cleanup**:
   - When leaving a buffer, highlights are cleared
   - When unloading a buffer, all plugin resources are released

## Component Interactions

The components interact in the following ways:

1. The **Configuration System** initializes the plugin and provides settings to all other components.

2. The **Filetype Integration** activates the plugin for specific file types and calls the Core Highlighting System.

3. The **Core Highlighting System** scans buffers, identifies code blocks, and applies highlighting based on configuration settings.

4. The **Language Support System** is called by the Core Highlighting System to provide language-specific syntax highlighting within code blocks.

5. The **Testing Framework** verifies the correct operation of all components.

## Design Patterns

The plugin employs several design patterns:

1. **Lazy Loading** - Core functionality is in autoload/ to minimize startup impact

2. **Configuration Registry** - Global variables serve as a central configuration registry

3. **Command Pattern** - User commands encapsulate operations like toggling and style changes

4. **Strategy Pattern** - Different strategies for line numbering based on Vim capabilities

5. **Observer Pattern** - Autocommands observe buffer changes to trigger highlighting updates

## Compatibility Considerations

The plugin is designed for maximum compatibility:

1. **Vim/Neovim Support** - Works in both Vim and Neovim with feature detection

2. **Graceful Degradation** - Falls back to simpler methods when advanced features aren't available

3. **Version Detection** - Checks Vim version for compatibility with certain features

4. **Error Handling** - Gracefully handles errors in highlight specifications

This architecture provides a robust foundation for the plugin's functionality while maintaining good performance and compatibility across different Vim environments.

# better-code-blocks - Lifecycle

This document describes the lifecycle of the better-code-blocks plugin, from initialization to cleanup, explaining how the plugin operates during different phases of Vim usage.

## Plugin Lifecycle Overview

The lifecycle of the better-code-blocks plugin can be divided into several distinct phases:

1. **Plugin Loading** - When Vim starts and loads plugins
2. **Buffer Activation** - When a supported file type is opened
3. **Highlighting Process** - When code blocks are detected and highlighted
4. **User Interaction** - When the user interacts with the plugin
5. **Buffer Cleanup** - When leaving or closing a buffer
6. **Plugin Unloading** - When Vim exits or the plugin is disabled

## 1. Plugin Loading

When Vim starts, it loads plugins in a specific order. The better-code-blocks plugin's loading sequence is:

### 1.1. Plugin Script Loading

The `plugin/better_code_blocks.vim` file is loaded first, which:

- Checks if the plugin is already loaded via `g:loaded_better_code_blocks`
- Sets default values for all configuration variables
- Calls `s:SetupPlugin()` to initialize the plugin environment

### 1.2. Plugin Setup

The `s:SetupPlugin()` function:

- Sets up the highlight style by calling `better_code_blocks#setup_highlight_style()`
- Configures line number display if enabled
- Creates autocommands for automatic highlighting
- Defines plugin commands

### 1.3. Initial Highlighting

If the current buffer has a supported file extension, the plugin immediately calls `better_code_blocks#apply_highlighting()` to apply highlighting to any code blocks in the current buffer.

## 2. Buffer Activation

When a user opens a file with a supported extension (default: md, markdown, txt), the plugin activates for that buffer.

### 2.1. Filetype Plugin Loading

The `ftplugin/markdown/better_code_blocks.vim` file is loaded, which:

- Checks if the plugin is already loaded for this buffer via `b:loaded_better_code_blocks`
- Initializes buffer-specific variables like `b:highlighting_enabled`
- Applies initial highlighting by calling `better_code_blocks#apply_highlighting()`
- Sets up buffer-local mappings and autocommands

### 2.2. Autocommand Registration

Buffer-specific autocommands are registered to:

- Update highlighting when the cursor moves in insert mode
- Clean up when leaving the buffer
- Clear highlights when unloading the buffer

## 3. Highlighting Process

The highlighting process is triggered by various events (buffer load, text change, user command) and follows a specific sequence.

### 3.1. Highlighting Trigger

Highlighting can be triggered by:

- Autocommands (BufReadPost, BufWritePost, InsertLeave, TextChanged, TextChangedI)
- User commands (`:BetterCodeBlocksRefresh`)
- Plugin functions (`better_code_blocks#enable()`, `better_code_blocks#toggle()`)

### 3.2. Debouncing (Optional)

If `g:better_code_blocks_update_delay` is greater than 0, the plugin debounces rapid changes:

- Cancels any pending update timer
- Starts a new timer that will call `better_code_blocks#do_apply_highlighting()` after the specified delay

### 3.3. Highlight Application

The `better_code_blocks#do_apply_highlighting()` function:

1. Clears previous highlights by calling `better_code_blocks#clear_highlights()`
2. Finds code blocks in the buffer by calling `s:find_code_blocks()`
3. For each code block:
   - Validates highlight line specifications
   - Applies highlighting to specified lines
   - Adds line numbers if enabled

### 3.4. Code Block Detection

The `s:find_code_blocks()` function:

1. Gets all lines in the buffer
2. Scans for fence patterns (``` or ~~~)
3. When a fence start is found:
   - Extracts highlight specifications
   - Detects the language
   - Tracks the code block content
4. When a fence end is found:
   - Completes the code block information
   - Adds it to the list of detected blocks

### 3.5. Highlight Specification Parsing

The `better_code_blocks#parse_highlight_spec()` function:

1. Extracts the highlight specification from the fence line
2. Parses it into an array of line numbers to highlight
3. Handles various formats (single lines, ranges, mixed)

### 3.6. Line Highlighting

For each line to highlight, the `s:highlight_line()` function:

1. Uses syntax matching to highlight the line
2. Adds match highlighting for full-width display
3. Uses 2match for additional coverage

### 3.7. Line Number Display

If line numbers are enabled, the `s:place_line_number()` function:

1. Determines the best method based on Vim capabilities
2. Places line numbers using the appropriate method:
   - Neovim virtual text
   - Vim text properties
   - Sign column

## 4. User Interaction

The plugin provides several ways for users to interact with it during runtime.

### 4.1. Toggling Highlighting

The `better_code_blocks#toggle()` function:

1. Checks the current state of `b:highlighting_enabled`
2. Toggles the state
3. Calls either `better_code_blocks#enable()` or `better_code_blocks#disable()`

### 4.2. Changing Highlight Style

The `better_code_blocks#change_highlight_style()` function:

1. Updates `g:better_code_blocks_style` with the new style
2. Calls `better_code_blocks#setup_highlight_style()` to apply the new style
3. Refreshes highlighting with `better_code_blocks#apply_highlighting()`

### 4.3. Toggling Line Numbers

The `better_code_blocks#toggle_line_numbers()` function:

1. Toggles `g:better_code_blocks_show_line_numbers`
2. Calls appropriate functions to enable or disable line numbers
3. Refreshes highlighting

### 4.4. Registering Custom Styles

The `better_code_blocks#register_custom_style()` function:

1. Parses style attributes from the command arguments
2. Adds the new style to `g:better_code_blocks_custom`

## 5. Buffer Cleanup

When the user navigates away from a buffer or closes it, cleanup occurs.

### 5.1. Leaving a Buffer

When the `BufLeave` event is triggered, the `s:cleanup()` function:

1. Clears the 2match highlighting

### 5.2. Unloading a Buffer

When the `BufUnload` event is triggered, the plugin:

1. Calls `better_code_blocks#clear_highlights()` to remove all highlighting
2. Clears line numbers
3. Releases all buffer-specific resources

## 6. Plugin Unloading

The plugin doesn't have explicit unloading code since Vim handles this automatically. However, the plugin is designed to clean up after itself when buffers are unloaded.

## Event-Driven Architecture

The plugin uses an event-driven architecture, responding to various Vim events:

| Event          | Handler                                      | Purpose                                               |
| -------------- | -------------------------------------------- | ----------------------------------------------------- |
| `BufReadPost`  | `better_code_blocks#apply_highlighting()`    | Initial highlighting after buffer load                |
| `BufWritePost` | `better_code_blocks#apply_highlighting()`    | Update highlighting after save                        |
| `InsertLeave`  | `better_code_blocks#apply_highlighting()`    | Update highlighting after exiting insert mode         |
| `TextChanged`  | `better_code_blocks#apply_highlighting()`    | Update highlighting after text changes in normal mode |
| `TextChangedI` | `better_code_blocks#apply_highlighting()`    | Update highlighting after text changes in insert mode |
| `CursorMovedI` | `better_code_blocks#apply_highlighting()`    | Update highlighting when cursor moves in insert mode  |
| `BufLeave`     | `s:cleanup()`                                | Clean up when leaving buffer                          |
| `BufUnload`    | `better_code_blocks#clear_highlights()`      | Clear highlights when buffer is unloaded              |
| `ColorScheme`  | `better_code_blocks#setup_highlight_style()` | Update highlight styles when colorscheme changes      |

## Resource Management

The plugin carefully manages resources to prevent memory leaks and ensure clean operation:

1. **Match IDs** - Stored in `w:better_code_blocks_match_ids` and cleared when needed
2. **Error Match IDs** - Stored in `w:better_code_blocks_error_match_ids` and cleared when needed
3. **Line Number Resources** - Managed differently based on the method:
   - Neovim namespace IDs
   - Vim text property IDs
   - Sign IDs

## Error Handling

The plugin includes error handling at various stages:

1. **Highlight Specification Validation** - Checks for invalid line numbers
2. **Match Deletion** - Wraps in try/catch to handle non-existent matches
3. **Feature Detection** - Checks for feature availability before using advanced features

This comprehensive lifecycle management ensures the plugin operates efficiently and cleans up after itself, providing a seamless experience for users while maintaining good performance and resource usage.

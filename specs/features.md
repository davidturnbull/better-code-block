# Better Code Blocks - Features

This document provides a detailed exploration of the features offered by the Better Fenced Code Block plugin, explaining how each feature works and how users can configure it.

## Line Highlighting

The core feature of the plugin is the ability to highlight specific lines within fenced code blocks in Markdown files.

### Highlight Specification Syntax

The plugin supports a flexible syntax for specifying which lines to highlight:

#### Basic Syntax

```markdown
```language highlight="line-spec"
code content
```
```

Where `line-spec` can be:

- **Single line**: `highlight="5"` - Highlights line 5
- **Multiple lines**: `highlight="1,3,5"` - Highlights lines 1, 3, and 5
- **Line range**: `highlight="1-3"` - Highlights lines 1 through 3 (inclusive)
- **Mixed format**: `highlight="1-3,5,7-9"` - Combines ranges and individual lines


#### Keyword Aliases

For convenience, the plugin supports multiple keywords that trigger highlighting:

- `highlight="1-3"` - Primary keyword
- `hl="1-3"` - Short alias
- `mark="1-3"` - Alternative alias
- `emphasize="1-3"` - Alternative alias

These aliases can be configured via `g:fenced_code_block_keyword_aliases`.

#### Quote Styles

The plugin is flexible with quote styles:

- Double quotes: ```python highlight="1-3"```
- Single quotes: ```python highlight='1-3'```
- No quotes: ```python highlight=1-3```

### Highlight Styles

The plugin offers multiple built-in highlight styles and allows users to create custom styles.

#### Built-in Styles

- **Color-based styles**:
  - `green` (default) - Green background with black text
  - `blue` - Blue background with white text
  - `yellow` - Yellow background with black text
  - `cyan` - Cyan background with black text
  - `magenta` - Magenta background with black text

- **Attribute-based styles**:
  - `invert` - Inverts foreground and background colors
  - `bold` - Makes text bold
  - `italic` - Makes text italic
  - `underline` - Underlines text
  - `undercurl` - Adds a curly underline

#### Custom Styles

Users can register custom highlight styles using the `FencedCodeBlockRegisterStyle` command:

```vim
:FencedCodeBlockRegisterStyle my_style cterm bold ctermfg red guifg #FF0000
```

This creates a style named `my_style` with the specified attributes.

#### Changing Styles

The active highlight style can be changed at runtime:

```vim
:FencedCodeBlockStyle blue
```

Or permanently in the user's vimrc:

```vim
let g:fenced_code_block_style = 'blue'
```

## Line Numbering

The plugin can display relative line numbers within code blocks to make it easier to reference specific lines.

### Line Number Display Methods

The plugin supports three methods for displaying line numbers:

1. **Neovim Virtual Text** (`nvim`) - Uses Neovim's virtual text feature (requires Neovim 0.5+)
2. **Vim Text Properties** (`prop`) - Uses Vim's text properties feature (requires Vim 8.1+ with +textprop)
3. **Sign Column** (`sign`) - Uses Vim's sign column (works in all Vim versions)

The method can be configured via `g:fenced_code_block_line_number_method` or set to `'auto'` to automatically select the best available method.

### Line Number Formatting

The format of line numbers can be customized:

```vim
let g:fenced_code_block_line_number_format = ' %d '  " Default
```

The `%d` placeholder is replaced with the actual line number.

### Toggling Line Numbers

Line numbers can be toggled on/off at runtime:

```vim
:FencedCodeBlockToggleLineNumbers
```

Or disabled permanently in the user's vimrc:

```vim
let g:fenced_code_block_show_line_numbers = 0
```

## Language Support

The plugin integrates with Vim's syntax highlighting system to provide language-specific highlighting within code blocks.

### Supported Languages

The plugin supports many common programming languages and their aliases, including:

- Python (`python`, `py`)
- JavaScript (`javascript`, `js`)
- TypeScript (`typescript`, `ts`)
- Ruby (`ruby`, `rb`)
- HTML (`html`)
- CSS (`css`)
- Shell (`bash`, `sh`)
- JSON (`json`)
- YAML (`yaml`, `yml`)
- Java (`java`)
- C (`c`)
- C++ (`cpp`, `c++`)
- Go (`go`)
- Rust (`rust`, `rs`)
- PHP (`php`)
- SQL (`sql`)
- XML (`xml`)
- Markdown (`markdown`, `md`, `mdx`)

### Language Detection

The plugin automatically detects the language from the fence line using various patterns:

- Standard format: ```python
- With attributes: ```python highlight="1-3"
- With spaces: ``` python
- With hyphens: ```shell-bash
- With extensions: ```config.json
- With curly braces: ```{java}

## Fence Patterns

The plugin supports multiple fence styles by default:

- Triple backticks: ```
- Triple tildes: ~~~

These patterns can be customized via `g:fenced_code_block_fence_patterns`:

```vim
let g:fenced_code_block_fence_patterns = [
      \ '^\(`\{3,}\)',
      \ '^\(\~\{3,}\)'
      \ ]
```

Each pattern must include a capture group for the fence characters.

## Commands

The plugin provides several commands for controlling its behavior at runtime:

- `:FencedCodeBlockRefresh` - Manually refresh highlighting
- `:FencedCodeBlockClear` - Clear all highlighting
- `:FencedCodeBlockToggleDebug` - Toggle debug mode
- `:FencedCodeBlockStyle {style}` - Change highlight style
- `:FencedCodeBlockToggleLineNumbers` - Toggle line numbers
- `:FencedCodeBlockRegisterStyle {name} {args...}` - Register custom style

## Mappings

The plugin provides a `<Plug>` mapping for toggling highlighting:

```vim
nmap <Leader>fh <Plug>(FencedCodeBlockToggle)
```

This mapping can be customized in the user's vimrc.

## Configuration

All plugin behavior can be configured through global variables in the user's vimrc:

| Variable | Default | Description |
|----------|---------|-------------|
| `g:fenced_code_block_style` | `'green'` | Default highlight style |
| `g:fenced_code_block_custom` | `{}` | Dictionary for custom styles |
| `g:fenced_code_block_debug` | `0` | Enable debug messages |
| `g:fenced_code_block_extensions` | `['md', 'markdown', 'txt']` | File extensions to activate on |
| `g:fenced_code_block_keyword` | `'highlight'` | Primary highlight keyword |
| `g:fenced_code_block_keyword_aliases` | `['hl', 'mark', 'emphasize']` | Alternative keywords |
| `g:fenced_code_block_show_line_numbers` | `1` | Show line numbers |
| `g:fenced_code_block_line_number_method` | `'auto'` | Line number display method |
| `g:fenced_code_block_line_number_format` | `' %d '` | Line number format |
| `g:fenced_code_block_line_number_style` | `'LineNr'` | Line number highlight group |
| `g:fenced_code_block_error_style` | `'red'` | Style for errors |
| `g:fenced_code_block_update_delay` | `0` | Delay before updating (ms) |
| `g:fenced_code_block_fence_patterns` | `['^\(`\{3,}\)', '^\(\~\{3,}\)']` | Fence patterns |
| `g:fenced_code_block_method` | `'background'` | Highlight method |

## Error Handling

The plugin provides visual feedback for errors in highlight specifications:

- Invalid line numbers (e.g., specifying line 10 in a 5-line block) are highlighted in the fence line
- The error style can be configured via `g:fenced_code_block_error_style`

## Performance Considerations

The plugin includes several features to maintain good performance:

- Lazy loading via autoload/ directory
- Optional update delay to debounce rapid changes
- Efficient parsing of highlight specifications
- Cleanup of resources when leaving buffers
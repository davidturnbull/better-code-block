# better-code-blocks

Enhances syntax highlighting within fenced code blocks in Markdown (and other supported files) by allowing specific lines to be highlighted. This is particularly useful for documentation, tutorials, and presentations where drawing attention to specific parts of code examples is necessary.

## Features

- **Line Highlighting:** Highlight specific lines or ranges within fenced code blocks using a simple attribute.
- **Flexible Syntax:** Supports single lines (`5`), multiple lines (`1,3,5`), ranges (`1-3`), and combinations (`1-3,5,8-10`).
- **Customizable Appearance:** Choose from pre-defined highlight styles (colors, bold, italic, etc.) or define your own.
- **Relative Line Numbering:** Optionally display relative line numbers within the code blocks.
- **Custom Line Number Start:** Define a custom starting value for line numbers with `start=10` attribute.
- **Multiple Keywords:** Use `highlight=`, `hl=`, `mark=`, or `emphasize=` to trigger highlighting.
- **Configurable:** Adjust filetypes, highlight styles, line number display, and more.
- **Multiple Fence Styles:** Supports `````and`~~~`fences by default, configurable via`g:better_code_blocks_fence_patterns`.
- **Supports Common Language Identifiers:** Recognizes many common language identifiers (like `python`, `javascript`, `ruby`, `bash`, `markdown`, `mdx`, etc.) for syntax highlighting within the blocks.

## Installation

Use your preferred Vim/Neovim plugin manager:

**vim-plug:**

```vim
Plug 'davidturnbull/better-code-blocks'
```

**Vundle:**

```vim
Plugin 'davidturnbull/better-code-blocks'
```

**Packer.nvim:**

```lua
use 'davidturnbull/better-code-blocks'
```

**lazy.nvim:**

```lua
{ 'davidturnbull/better-code-blocks', ft = { "markdown", "txt" } } -- Adjust ft as needed
```

Remember to replace `'davidturnbull/better-code-blocks'` with the actual repository path once published. Then run the appropriate install command (e.g., `:PlugInstall`, `:PluginInstall`).

## Usage

The plugin automatically activates for supported filetypes (default: `markdown`, `md`, `txt`). To highlight lines in a fenced code block, add a `highlight` attribute (or one of its aliases: `hl`, `mark`, `emphasize`) to the opening fence line, followed by the line numbers or ranges you want to highlight.

**Example:**

````markdown
```python hl="2, 4-5"
def greet(name):
  print(f"Hello, {name}!") # This line will be highlighted

def farewell(name): # This line will be highlighted
  print(f"Goodbye, {name}!") # This line will be highlighted
```
````

This will apply the configured highlight style to line 2 and lines 4 through 5 of the Python code block.

**Supported Formats for the `highlight` attribute:**

- Single line: `highlight="3"`
- Multiple lines: `highlight="1,3,5"`
- Line ranges: `highlight="1-3"`
- Mixed: `highlight="1-3,5,7-9"`

## Configuration

Configure the plugin by setting various global variables in your vim configuration file (vimrc, init.vim, or init.lua). Below are the available configuration options along with examples:

- g:better_code_blocks_style (default: 'green')
  This variable sets the default highlight style. Built-in styles include 'green', 'blue', 'yellow', 'cyan', 'magenta', 'invert', 'bold', 'italic', 'underline', and 'undercurl'.
  Example:
      let g:better_code_blocks_style = 'blue'

- g:better_code_blocks_custom (default: {})
  Use this dictionary to register custom styles.
  Example:
      call BetterCodeBlocksRegisterStyle('my_cyan', 'ctermbg=cyan', 'guibg=#00FFFF', 'cterm=bold', 'gui=bold')
      let g:better_code_blocks_style = 'my_cyan'

- g:better_code_blocks_debug (default: 0)
  Enable debug messages by setting this to 1.
  Example:
      let g:better_code_blocks_debug = 1

- g:better_code_blocks_extensions (default: ['md', 'markdown', 'txt'])
  Specifies the file extensions on which the plugin is active.
  Example:
      let g:better_code_blocks_extensions = ['md']

- g:better_code_blocks_keyword (default: 'highlight')
  Defines the primary keyword to trigger highlighting in fenced code blocks.
  Example:
      let g:better_code_blocks_keyword = 'highlight'

- g:better_code_blocks_keyword_aliases (default: ['hl', 'mark', 'emphasize'])
  Alternative keywords for triggering highlights.
  Example:
      let g:better_code_blocks_keyword_aliases = ['hl', 'mark']

- g:better_code_blocks_start_keyword (default: 'start')
  Primary keyword for setting the starting line number.
  Example:
      let g:better_code_blocks_start_keyword = 'start'

- g:better_code_blocks_start_keyword_aliases (default: ['from', 'begin'])
  Alternative keywords for defining the starting line number.
  Example:
      let g:better_code_blocks_start_keyword_aliases = ['from']

- g:better_code_blocks_show_line_numbers (default: 1)
  Controls the display of line numbers within code blocks.
  Allowed values:
    1 or 'always'       – always show line numbers.
    0 or 'never'        – never show line numbers.
    'with_highlights'   – show only when highlights are applied.
  Example:
      let g:better_code_blocks_show_line_numbers = 'with_highlights'

- g:better_code_blocks_line_number_method (default: 'auto')
  Selects the method for displaying line numbers. Options include 'nvim' (virtual text), 'prop' (text properties), 'sign' (sign column), or 'auto' (to choose the best available).
  Example:
      let g:better_code_blocks_line_number_method = 'nvim'

- g:better_code_blocks_line_number_format (default: ' %d ')
  Format string for line numbers, where %d is replaced by the actual line number.
  Example:
      let g:better_code_blocks_line_number_format = ' %d '

- g:better_code_blocks_line_number_style (default: 'LineNr')
  The highlight group used for line numbers.
  Example:
      let g:better_code_blocks_line_number_style = 'LineNr'

- g:better_code_blocks_error_style (default: 'red')
  Specifies the style used to indicate errors (e.g., invalid line numbers).
  Example:
      let g:better_code_blocks_error_style = 'red'

- g:better_code_blocks_update_delay (default: 0)
  Delay in milliseconds before updating highlights after changes.
  Example:
      let g:better_code_blocks_update_delay = 0

- g:better_code_blocks_fence_patterns (default: ['^\(\{3,}\)', '^\(\~\{3,}\)'])
  Vim regex patterns used to detect fence lines (must capture the fence characters).
  Example:
      let g:better_code_blocks_fence_patterns = ['^\(\{3,}\)', '^\(\~\{3,}\)']

- g:better_code_blocks_method (default: 'background')
  Determines the highlighting method. Options include 'background', 'foreground', 'underline', 'undercurl', 'bold', 'italic', and 'reverse'.
  Example:
      let g:better_code_blocks_method = 'underline'

Built-in styles available: 'green', 'blue', 'yellow', 'cyan', 'magenta', 'invert', 'bold', 'italic', 'underline', 'undercurl'

**Built-in Styles:** `'green'`, `'blue'`, `'yellow'`, `'cyan'`, `'magenta'`, `'invert'`, `'bold'`, `'italic'`, `'underline'`, `'undercurl'`

**Configuration Examples:**

```vim
" Use the 'yellow' background style
let g:better_code_blocks_style = 'yellow'

" Disable line numbers within code blocks
let g:better_code_blocks_show_line_numbers = 0

" Only activate for .md files
let g:better_code_blocks_extensions = ['md']

" Register and use a custom style (bold, bright cyan background)
call BetterCodeBlocksRegisterStyle('my_cyan', 'ctermbg=cyan', 'guibg=#00FFFF', 'cterm=bold', 'gui=bold')
let g:better_code_blocks_style = 'my_cyan'
```

## Commands

- `:BetterCodeBlocksRefresh` : Manually re-apply highlighting in the current buffer.
- `:BetterCodeBlocksClear` : Clear all highlighting applied by the plugin in the current buffer.
- `:BetterCodeBlocksToggleDebug` : Toggle debug mode on/off.
- `:BetterCodeBlocksStyle {style}` : Change the active highlight style (e.g., `:BetterCodeBlocksStyle blue`). Supports completion for available styles.
- `:BetterCodeBlocksToggleLineNumbers` : Toggle the display of relative line numbers on/off.
- `:BetterCodeBlocksRegisterStyle {name} {args...}` : Register a custom highlight style. Args are pairs of `key` `value` for `highlight` command (e.g., `ctermfg`, `guibg`). Example: `:BetterCodeBlocksRegisterStyle my_error guibg=Red ctermbg=red gui=bold cterm=bold`

## Mappings

The plugin does not provide default mappings but exposes a `<Plug>` mapping for toggling:

- `<Plug>(BetterCodeBlocksToggle)`: Toggles highlighting on/off for the current buffer.

You can map this in your configuration:

```vim
" Example mapping: <Leader>fh to toggle highlighting
nmap <Leader>fh <Plug>(BetterCodeBlocksToggle)
```

## License

This plugin is distributed under the same terms as Vim itself. See `:help license`.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Acknowledgements

- This plugin was initially created with assistance from Claude.
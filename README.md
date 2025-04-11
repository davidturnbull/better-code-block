# better-fenced-code-block

Enhances syntax highlighting within fenced code blocks in Markdown (and other supported files) by allowing specific lines to be highlighted. This is particularly useful for documentation, tutorials, and presentations where drawing attention to specific parts of code examples is necessary.

## Features

- **Line Highlighting:** Highlight specific lines or ranges within fenced code blocks using a simple attribute.
- **Flexible Syntax:** Supports single lines (`5`), multiple lines (`1,3,5`), ranges (`1-3`), and combinations (`1-3,5,8-10`).
- **Customizable Appearance:** Choose from pre-defined highlight styles (colors, bold, italic, etc.) or define your own.
- **Relative Line Numbering:** Optionally display relative line numbers within the code blocks.
- **Multiple Keywords:** Use `highlight=`, `hl=`, `mark=`, or `emphasize=` to trigger highlighting.
- **Configurable:** Adjust filetypes, highlight styles, line number display, and more.
- **Multiple Fence Styles:** Supports `````and`~~~`fences by default, configurable via`g:better_fenced_code_block_fence_patterns`.

## Installation

Use your preferred Vim/Neovim plugin manager:

**vim-plug:**

```vim
Plug 'davidturnbull/better-fenced-code-block'
```

**Vundle:**

```vim
Plugin 'davidturnbull/better-fenced-code-block'
```

**Packer.nvim:**

```lua
use 'davidturnbull/better-fenced-code-block'
```

**lazy.nvim:**

```lua
{ 'davidturnbull/better-fenced-code-block', ft = { "markdown", "txt" } } -- Adjust ft as needed
```

Remember to replace `'davidturnbull/better-fenced-code-block'` with the actual repository path once published. Then run the appropriate install command (e.g., `:PlugInstall`, `:PluginInstall`).

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
- Colon as separator: `highlight="1-3:5"` (equivalent to `1-3,5`)

## Configuration

Configure the plugin by setting the following global variables in your `vimrc` or `init.vim`/`init.lua`.

| Variable                                        | Default                           | Description                                                                                                                                 |
| :---------------------------------------------- | :-------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `g:better_fenced_code_block_style`              | `'green'`                         | Default highlight style. See built-in styles below or register custom ones.                                                                 |
| `g:better_fenced_code_block_custom`             | `{}`                              | Dictionary for storing definition of custom highlight styles.                                                                               |
| `g:better_fenced_code_block_debug`              | `0`                               | Set to `1` to enable debug messages.                                                                                                        |
| `g:better_fenced_code_block_extensions`         | `['md', 'markdown', 'txt']`       | List of file extensions where the plugin should be active.                                                                                  |
| `g:better_fenced_code_block_keyword`            | `'highlight'`                     | The primary keyword to look for in the fence line.                                                                                          |
| `g:better_fenced_code_block_keyword_aliases`    | `['hl', 'mark', 'emphasize']`     | Alternative keywords that trigger highlighting.                                                                                             |
| `g:better_fenced_code_block_show_line_numbers`  | `1`                               | Set to `0` to disable relative line numbers inside highlighted blocks.                                                                      |
| `g:better_fenced_code_block_line_number_method` | `'auto'`                          | Method for displaying line numbers: `'nvim'` (virtual text), `'prop'` (text properties), `'sign'` (sign column), `'auto'` (best available). |
| `g:better_fenced_code_block_line_number_format` | `' %d '`                          | Format string for line numbers (`%d` is the line number).                                                                                   |
| `g:better_fenced_code_block_line_number_style`  | `'LineNr'`                        | Highlight group used for the line numbers.                                                                                                  |
| `g:better_fenced_code_block_error_style`        | `'red'`                           | Style used to indicate errors (e.g., invalid line numbers).                                                                                 |
| `g:better_fenced_code_block_update_delay`       | `0`                               | Delay (in milliseconds) before updating highlights after changes (0=immediate).                                                             |
| `g:better_fenced_code_block_fence_patterns`     | `['^\(`\{3,}\)', '^\(\~\{3,}\)']` | List of Vim regex patterns to detect fence lines. Must capture the fence chars.                                                             |
| `g:better_fenced_code_block_method`             | `'background'`                    | Highlighting method: `'background'`, `'foreground'`, `'underline'`, `'undercurl'`, `'bold'`, `'italic'`, `'reverse'`.                       |

**Built-in Styles:** `'green'`, `'blue'`, `'yellow'`, `'cyan'`, `'magenta'`, `'invert'`, `'bold'`, `'italic'`, `'underline'`, `'undercurl'`

**Configuration Examples:**

```vim
" Use the 'yellow' background style
let g:better_fenced_code_block_style = 'yellow'

" Disable line numbers within code blocks
let g:better_fenced_code_block_show_line_numbers = 0

" Only activate for .md files
let g:better_fenced_code_block_extensions = ['md']

" Register and use a custom style (bold, bright cyan background)
call BetterFencedCodeBlockRegisterStyle('my_cyan', 'ctermbg=cyan', 'guibg=#00FFFF', 'cterm=bold', 'gui=bold')
let g:better_fenced_code_block_style = 'my_cyan'
```

## Commands

- `:BetterFencedCodeBlockRefresh` : Manually re-apply highlighting in the current buffer.
- `:BetterFencedCodeBlockClear` : Clear all highlighting applied by the plugin in the current buffer.
- `:BetterFencedCodeBlockToggleDebug` : Toggle debug mode on/off.
- `:BetterFencedCodeBlockStyle {style}` : Change the active highlight style (e.g., `:BetterFencedCodeBlockStyle blue`). Supports completion for available styles.
- `:BetterFencedCodeBlockToggleLineNumbers` : Toggle the display of relative line numbers on/off.
- `:BetterFencedCodeBlockRegisterStyle {name} {args...}` : Register a custom highlight style. Args are pairs of `key` `value` for `highlight` command (e.g., `ctermfg`, `guibg`). Example: `:BetterFencedCodeBlockRegisterStyle my_error guibg=Red ctermbg=red gui=bold cterm=bold`

## Mappings

The plugin does not provide default mappings but exposes a `<Plug>` mapping for toggling:

- `<Plug>(BetterFencedCodeBlockToggle)`: Toggles highlighting on/off for the current buffer.

You can map this in your configuration:

```vim
" Example mapping: <Leader>fh to toggle highlighting
nmap <Leader>fh <Plug>(BetterFencedCodeBlockToggle)
```

## License

This plugin is distributed under the same terms as Vim itself. See `:help license`.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Acknowledgements

- This plugin was initially created with assistance from Claude.

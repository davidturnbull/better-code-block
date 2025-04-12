# ✨ better-code-block

> ✍️ Enhanced syntax highlighting for fenced code blocks in Markdown and beyond.

`better-code-block` makes your code samples pop. Whether you're writing tutorials, documentation, or slides, this plugin lets you **highlight specific lines** in fenced code blocks with ease — and style.

---

## 🔧 Features

- 🎯 **Targeted Line Highlighting**: Highlight specific lines or ranges with intuitive syntax.
- 🧠 **Smart Syntax**: Supports single lines (`5`), ranges (`2-4`), and combos (`1,3-5,7`).
- 🎨 **Custom Highlight Styles**: Choose built-in styles or roll your own.
- 🔢 **Line Numbers**: Show relative or absolute line numbers, with flexible formatting.
- 🏷️ **Multiple Attribute Keywords**: `highlight=`, `hl=`, `mark=`, or `emphasize=`.
- 🧬 **Configurable Behavior**: Tweak behavior via Vim globals.
- ✍️ **Fence-Style Agnostic**: Works with `````and`~~~` fences.
- 🧠 **Language-Aware**: Plays well with `python`, `js`, `bash`, `mdx`, and more.

---

## 🚀 Installation

Install using your favorite plugin manager:

<details>
<summary><strong>vim-plug</strong></summary>

```vim
Plug 'davidturnbull/better-code-block'
```

</details>

<details>
<summary><strong>Vundle</strong></summary>

```vim
Plugin 'davidturnbull/better-code-block'
```

</details>

<details>
<summary><strong>Packer.nvim</strong></summary>

```lua
use 'davidturnbull/better-code-block'
```

</details>

<details>
<summary><strong>lazy.nvim</strong></summary>

```lua
{ 'davidturnbull/better-code-block', ft = { "markdown", "txt" } }
```

</details>

---

## ✨ Usage

Just annotate your fenced code blocks using a supported highlight keyword (`hl`, `highlight`, etc.).

<details>
<summary><strong>Example</strong></summary>

<pre lang="markdown"><code>```python hl="2, 4-5"
def greet(name):
  print(f"Hello, {name}!")  # Highlighted

def farewell(name):         # Highlighted
  print(f"Goodbye, {name}!")# Highlighted
```</code></pre>
</details>

### ✅ Supported Attribute Syntax

| Format         | Example          |
| -------------- | ---------------- |
| Single line    | `hl="3"`         |
| Multiple lines | `hl="1,3,5"`     |
| Line ranges    | `hl="2-4"`       |
| Mixed          | `hl="1-3,5,7-9"` |

---

## ⚙️ Configuration

Customize behavior by setting global variables in your `vimrc`, `init.vim`, or `init.lua`.

<details>
<summary><strong>Common Options</strong></summary>

```vim
" Highlight style (built-in styles listed below)
let g:better_code_block_style = 'yellow'

" Show line numbers only when highlights are applied
let g:better_code_block_show_line_numbers = 'with_highlights'

" Limit to markdown files
let g:better_code_block_extensions = ['md']

" Register a custom style
call BetterCodeBlockRegisterStyle('my_cyan', 'ctermbg=cyan', 'guibg=#00FFFF', 'cterm=bold', 'gui=bold')
let g:better_code_block_style = 'my_cyan'
```

</details>

### 🖌️ Built-in Highlight Styles

`green`, `blue`, `yellow`, `cyan`, `magenta`, `invert`, `bold`, `italic`, `underline`, `undercurl`

<details>
<summary><strong>Full Configuration Reference</strong></summary>

| Variable                                    | Description                                           |
| ------------------------------------------- | ----------------------------------------------------- |
| `g:better_code_block_style`                 | Default highlight style                               |
| `g:better_code_block_custom`                | Define custom styles                                  |
| `g:better_code_block_debug`                 | Enable debug mode (1 = on)                            |
| `g:better_code_block_extensions`            | Filetypes/extensions to activate plugin               |
| `g:better_code_block_keyword`               | Keyword to trigger highlight (`highlight`)            |
| `g:better_code_block_keyword_aliases`       | Aliases: `hl`, `mark`, `emphasize`                    |
| `g:better_code_block_start_keyword`         | Keyword to define starting line                       |
| `g:better_code_block_start_keyword_aliases` | Aliases: `from`, `begin`                              |
| `g:better_code_block_show_line_numbers`     | `'always'`, `'never'`, or `'with_highlights'`         |
| `g:better_code_block_line_number_method`    | `'nvim'`, `'prop'`, `'sign'`, `'auto'`                |
| `g:better_code_block_line_number_format`    | Format string (e.g. `' %d '`)                         |
| `g:better_code_block_line_number_style`     | Highlight group for line numbers                      |
| `g:better_code_block_error_style`           | Style for error lines                                 |
| `g:better_code_block_update_delay`          | Delay in ms before update                             |
| `g:better_code_block_fence_patterns`        | Regex to detect fence lines                           |
| `g:better_code_block_method`                | Highlighting method (`background`, `underline`, etc.) |

</details>

---

## 🧩 Commands

| Command                                          | Description                       |
| ------------------------------------------------ | --------------------------------- |
| `:BetterCodeBlockRefresh`                        | Re-apply highlights in the buffer |
| `:BetterCodeBlockClear`                          | Clear highlights in the buffer    |
| `:BetterCodeBlockToggleDebug`                    | Toggle debug mode                 |
| `:BetterCodeBlockStyle {style}`                  | Change highlight style            |
| `:BetterCodeBlockToggleLineNumbers`              | Toggle relative line numbers      |
| `:BetterCodeBlockRegisterStyle {name} {args...}` | Register a custom style           |

---

## 🎯 Mappings

No default mappings, but expose a toggle:

```vim
" Toggle better-code-block highlighting with <Leader>fh
nmap <Leader>fh <Plug>(BetterCodeBlockToggle)
```

---

## 🤝 Contributing

Contributions are welcome! Open an issue, suggest an idea, or submit a pull request.

---

## 📄 License

Distributed under the same terms as Vim itself. See `:help license`.

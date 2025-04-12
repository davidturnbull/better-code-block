# ✨ better-code-block

> Enhanced syntax highlighting for fenced code blocks in Markdown and beyond.

**better-code-block** lets you highlight specific lines inside fenced code blocks using intuitive attributes. It’s ideal for documentation, tutorials, and slides where drawing attention to code matters.

---

## 🔧 Features

- 🎯 **Targeted line highlighting** – Highlight specific lines or ranges with intuitive syntax.
- 🧠 **Smart attributes** – Use `highlight=`, `hl=`, `mark=`, or `emphasize=` for flexibility.
- 🖌️ **Custom styles** – Choose from built-in themes or register your own.
- 🔢 **Line numbers** – Show relative or absolute numbers, configurable and themeable.
- ✍️ **Fence-style agnostic** – Works with both ` ``` ` and `~~~` fences.
- 🌐 **Language-aware** – Supports popular identifiers like `python`, `js`, `bash`, `markdown`, `mdx`, and more.

---

## 🚀 Installation

Install using your preferred plugin manager:

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

## 📚 Usage examples

These examples assume the plugin is active for Markdown files.

### 🔸 Highlight a single line

````markdown
```js hl="3"
function sayHi() {
  const name = "Alice";
  console.log("Hello, " + name); // ← highlighted
}
```
````

### 🔸 Highlight multiple lines

````markdown
```ts highlight="2,4"
const nums = [1, 2, 3]; // ← highlighted
const squared = nums.map((n) => n * n);
console.log(squared); // ← highlighted
```
````

### 🔸 Highlight a line range

````markdown
```python hl="1-2"
def login():
    check_credentials()   # ← highlighted
    log_user_in()
```
````

### 🔸 Mix single lines and ranges

````markdown
```go mark="1-2,4"
func main() {
    doThing()
    log.Println("done")
    cleanUp()
}
```
````

### 🔸 Use alternative attribute names

````markdown
```sh emphasize="2"
#!/bin/bash
echo "Important!"         # ← highlighted
exit 0
```
````

### 🔸 Set a custom starting line number

````markdown
```c start="10" hl="11"
int main() {
  return 0;               // Line shown as "11" and highlighted
}
```
````

### 🔸 Show line numbers (always)

```vim
let g:better_code_block_show_line_numbers = 'always'
```

````markdown
```ruby hl="2"
def greet(name)
  puts "Hi #{name}"       # ← highlighted
end
```
````

### 🔸 Show line numbers only with highlights

```vim
let g:better_code_block_show_line_numbers = 'with_highlights'
```

````markdown
```rust hl="3"
fn main() {
    let name = "Rust";
    println!("Hello, {}", name); // ← highlighted
}
```
````

### 🔸 Use a custom highlight style

```vim
call BetterCodeBlockRegisterStyle('warning', 'guibg=#FFDD57', 'gui=bold')
let g:better_code_block_style = 'warning'
```

````markdown
```json highlight="1"
{ "warning": "This config is deprecated" } // ← yellow + bold
```
````

### 🔸 Invalid line numbers are ignored gracefully

````markdown
```ts hl="10"
console.log("This is line 1");
// Line 10 doesn't exist, nothing breaks
```
````

### 🔸 Toggle highlighting with a key mapping

```vim
nmap <Leader>hh <Plug>(BetterCodeBlockToggle)
```

## ⚙️ Configuration

Set these variables in your Vim config (`vimrc`, `init.vim`, or `init.lua`):

<details>
<summary><strong>Examples</strong></summary>

```vim
" Use the 'yellow' background style
let g:better_code_block_style = 'yellow'

" Disable line numbers
let g:better_code_block_show_line_numbers = 0

" Only activate for markdown files
let g:better_code_block_extensions = ['md']

" Register and use a custom style
call BetterCodeBlockRegisterStyle('my_cyan', 'ctermbg=cyan', 'guibg=#00FFFF', 'cterm=bold', 'gui=bold')
let g:better_code_block_style = 'my_cyan'
```

</details>

<details>
<summary><strong>Full list of config options</strong></summary>

| Variable                                    | Description                                         |
| ------------------------------------------- | --------------------------------------------------- |
| `g:better_code_block_style`                 | Default highlight style (`'green'`, `'bold'`, etc.) |
| `g:better_code_block_custom`                | Register your own styles                            |
| `g:better_code_block_debug`                 | Set to `1` to enable debug logging                  |
| `g:better_code_block_extensions`            | Filetypes/extensions to match                       |
| `g:better_code_block_keyword`               | Main keyword (`highlight`)                          |
| `g:better_code_block_keyword_aliases`       | Additional accepted keywords                        |
| `g:better_code_block_start_keyword`         | Line number start keyword (`start`)                 |
| `g:better_code_block_start_keyword_aliases` | Aliases like `from`, `begin`                        |
| `g:better_code_block_show_line_numbers`     | `'always'`, `'never'`, `'with_highlights'`          |
| `g:better_code_block_line_number_method`    | `'nvim'`, `'prop'`, `'sign'`, or `'auto'`           |
| `g:better_code_block_line_number_format`    | Format string (e.g. `' %d '`)                       |
| `g:better_code_block_line_number_style`     | Highlight group for line numbers                    |
| `g:better_code_block_error_style`           | Style for invalid lines                             |
| `g:better_code_block_update_delay`          | Delay before highlight refresh                      |
| `g:better_code_block_fence_patterns`        | Vim regex to match fences                           |
| `g:better_code_block_method`                | Highlight method (`background`, `underline`, etc.)  |

</details>

---

## 🔌 Commands

| Command                                          | Description                                  |
| ------------------------------------------------ | -------------------------------------------- |
| `:BetterCodeBlockRefresh`                        | Re-apply highlights in the buffer            |
| `:BetterCodeBlockClear`                          | Clear all applied highlights                 |
| `:BetterCodeBlockToggleDebug`                    | Toggle debug mode                            |
| `:BetterCodeBlockStyle {style}`                  | Switch highlight style (e.g. `blue`, `bold`) |
| `:BetterCodeBlockToggleLineNumbers`              | Toggle relative line numbers                 |
| `:BetterCodeBlockRegisterStyle {name} {args...}` | Register a new custom style                  |

---

## 🎯 Mappings

This plugin is unmapped by default. It exposes a `<Plug>` key:

```vim
" Toggle highlighting
nmap <Leader>fh <Plug>(BetterCodeBlockToggle)
```

---

## 📄 License

Distributed under the same terms as Vim itself. See `:help license`.

---

## 🤝 Contributing

PRs welcome! Open an issue to suggest a feature or report a bug.

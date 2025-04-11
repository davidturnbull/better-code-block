" better-fenced-code-block.vim - Improved syntax highlighting for fenced code blocks
" Maintainer: Your Name <your.email@example.com>
" Version: 0.1
" License: Same as Vim

if exists('g:loaded_better_fenced_code_block')
  finish
endif
let g:loaded_better_fenced_code_block = 1

" Default configuration
if !exists('g:better_fenced_code_block_enabled')
  let g:better_fenced_code_block_enabled = 1
endif

" Commands
command! -nargs=0 BetterFencedCodeBlockEnable let g:better_fenced_code_block_enabled = 1
command! -nargs=0 BetterFencedCodeBlockDisable let g:better_fenced_code_block_enabled = 0
command! -nargs=0 BetterFencedCodeBlockToggle let g:better_fenced_code_block_enabled = !g:better_fenced_code_block_enabled

" Load autoload functions
" Core plugin functionality will be in autoload/better_fenced_code_block.vim 

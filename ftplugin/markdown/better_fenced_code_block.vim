" Filetype plugin for better fenced code block highlighting in markdown files
" This file is automatically loaded when editing markdown files if ftplugin is enabled

" Only load this plugin once per buffer
if exists('b:loaded_better_fenced_code_block')
  finish
endif
let b:loaded_better_fenced_code_block = 1

" Check if plugin is enabled globally
if !exists('g:better_fenced_code_block_enabled') || !g:better_fenced_code_block_enabled
  finish
endif

" Settings specific to markdown files
setlocal conceallevel=2
setlocal concealcursor=nc

" Syntax highlighting enhancements for fenced code blocks
syntax region betterFencedCodeBlock matchgroup=markdownCodeDelimiter
  \ start='^```\s*\(\w\+\)\?\s*$'
  \ end='^```\s*$'
  \ keepend
  \ contains=@NoSpell

" Auto-commands
augroup better_fenced_code_block
  autocmd!
  autocmd BufEnter <buffer> call better_fenced_code_block#enable()
  autocmd BufLeave <buffer> call s:cleanup()
augroup END

" Local cleanup function
function! s:cleanup()
  " Cleanup any buffer-specific settings or highlights
endfunction

" Buffer-local mappings
nnoremap <buffer> <Plug>(BetterFencedCodeBlockToggle) :call better_fenced_code_block#toggle()<CR>

" Default mapping for toggle
if !hasmapto('<Plug>(BetterFencedCodeBlockToggle)')
  nmap <buffer> <Leader>bt <Plug>(BetterFencedCodeBlockToggle)
endif 

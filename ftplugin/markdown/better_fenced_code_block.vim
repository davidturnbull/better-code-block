" Filetype plugin for better fenced code block highlighting in markdown files
" This file is automatically loaded when editing markdown files if ftplugin is enabled

" Only load this plugin once per buffer
if exists('b:loaded_better_fenced_code_block')
  finish
endif
let b:loaded_better_fenced_code_block = 1

" Initialize buffer-specific variables
let b:highlighting_enabled = 1

" Apply highlighting automatically for markdown files
call better_fenced_code_block#apply_highlighting()

" Buffer-local mappings
nnoremap <buffer> <Plug>(BetterFencedCodeBlockToggle) :call better_fenced_code_block#toggle()<CR>

" Add default mapping for toggle
if !hasmapto('<Plug>(BetterFencedCodeBlockToggle)')
  nmap <buffer> <Leader>bt <Plug>(BetterFencedCodeBlockToggle)
endif

" Auto-commands for this buffer
augroup better_fenced_code_block_buffer
  autocmd!
  " Update highlighting when moving cursor to a new line in insert mode
  autocmd CursorMovedI <buffer> call better_fenced_code_block#apply_highlighting()
  " Cleanup when leaving buffer
  autocmd BufLeave <buffer> call s:cleanup()
augroup END

" Local cleanup function
function! s:cleanup()
  " Cleanup any buffer-specific settings or highlights
  2match none
endfunction

" When closing the buffer, clean up highlights
autocmd BufUnload <buffer> call better_fenced_code_block#clear_highlights() 

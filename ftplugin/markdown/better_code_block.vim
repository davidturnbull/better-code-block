" Filetype plugin for Better Code Blocks highlighting in markdown files
" This file is automatically loaded when editing markdown files if ftplugin is enabled

if exists('b:loaded_better_code_block')
  finish
endif
let b:loaded_better_code_block = 1

if !exists('g:better_code_block_update_delay')
  let g:better_code_block_update_delay = 0
endif

let b:highlighting_enabled = 1

call better_code_block#apply_highlighting()

nnoremap <buffer> <Plug>(BetterCodeBlockToggle) :call better_code_block#toggle()<CR>

if !hasmapto('<Plug>(BetterCodeBlockToggle)')
  nmap <buffer> <Leader>bt <Plug>(BetterCodeBlockToggle)
endif

augroup better_code_block_buffer
  autocmd!
  autocmd CursorMovedI <buffer> call better_code_block#apply_highlighting()
  autocmd BufLeave <buffer> call s:cleanup()
augroup END

function! s:cleanup()
  2match none
endfunction

autocmd BufUnload <buffer> call better_code_block#clear_highlights()

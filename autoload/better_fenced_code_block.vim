" Autoload functions for better-fenced-code-block
" Functions in this file will be automatically loaded when called

function! better_fenced_code_block#enable()
  if g:better_fenced_code_block_enabled
    call s:setup_highlighting()
    echo 'Better Fenced Code Block enabled'
  endif
endfunction

function! better_fenced_code_block#disable()
  let g:better_fenced_code_block_enabled = 0
  echo 'Better Fenced Code Block disabled'
endfunction

function! better_fenced_code_block#toggle()
  let g:better_fenced_code_block_enabled = !g:better_fenced_code_block_enabled
  if g:better_fenced_code_block_enabled
    call better_fenced_code_block#enable()
  else
    call better_fenced_code_block#disable()
  endif
endfunction

" Private functions
function! s:setup_highlighting()
  " Implementation for improved fenced code block highlighting
  " This would detect and highlight fenced code blocks with proper syntax
endfunction

" Additional helper functions
function! s:detect_language(fence_line)
  " Parse the language from the fence line
  " Example: ```python -> 'python'
  let matches = matchlist(a:fence_line, '```\s*\(\w\+\)')
  if len(matches) > 1 && !empty(matches[1])
    return matches[1]
  endif
  return ''
endfunction 

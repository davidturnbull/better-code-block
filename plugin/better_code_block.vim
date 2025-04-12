" better_code_block.vim - Improved syntax highlighting for code blocks
" Maintainer: Created with Claude
" Version: 2.1
" License: Same as Vim

if exists("g:loaded_better_code_block")
  finish
endif
let g:loaded_better_code_block = 1

if !exists('g:better_code_block_style')
  let g:better_code_block_style = 'green'
endif

if !exists('g:better_code_block_custom')
  let g:better_code_block_custom = {}
endif

if !exists('g:better_code_block_debug')
  let g:better_code_block_debug = 0
endif

if !exists('g:better_code_block_extensions')
  let g:better_code_block_extensions = ['md', 'markdown', 'txt']
endif

if !exists('g:better_code_block_keyword')
  let g:better_code_block_keyword = 'highlight'
endif

if !exists('g:better_code_block_keyword_aliases')
  let g:better_code_block_keyword_aliases = ['hl', 'mark', 'emphasize']
endif

if !exists('g:better_code_block_start_keyword')
  let g:better_code_block_start_keyword = 'start'
endif

if !exists('g:better_code_block_start_keyword_aliases')
  let g:better_code_block_start_keyword_aliases = ['from', 'begin']
endif

if !exists('g:better_code_block_show_line_numbers')
  let g:better_code_block_show_line_numbers = 1
endif

if !exists('g:better_code_block_line_number_method')
  let g:better_code_block_line_number_method = 'auto'
endif

if !exists('g:better_code_block_line_number_format')
  let g:better_code_block_line_number_format = ' %d '
endif

if !exists('g:better_code_block_line_number_style')
  let g:better_code_block_line_number_style = 'LineNr'
endif

if !exists('g:better_code_block_error_style')
  let g:better_code_block_error_style = 'red'
endif

if !exists('g:better_code_block_update_delay')
  let g:better_code_block_update_delay = 0
endif

if !exists('g:better_code_block_fence_patterns')
  let g:better_code_block_fence_patterns = [
        \ '^\(`\{3,}\).*$',
        \ '^\([\~]\{3,}\).*$'
        \ ]
endif

if !exists('g:better_code_block_method')
  let g:better_code_block_method = 'background'
endif

function! s:SetupPlugin()
  call better_code_block#setup_highlight_style()
  
  if g:better_code_block_show_line_numbers
    set number
    let method = g:better_code_block_line_number_method
    if method == 'auto' && !has('nvim-0.5') && !exists('*prop_type_add')
      set signcolumn=yes:1
    elseif method == 'sign'
      set signcolumn=yes:1
    endif
  endif
  
  let extensions = join(map(copy(g:better_code_block_extensions), '"*." . v:val'), ',')
  
  augroup BetterCodeBlock
    autocmd!
    execute 'autocmd BufReadPost,BufWritePost ' . extensions . ' call better_code_block#apply_highlighting()'
    execute 'autocmd InsertLeave ' . extensions . ' call better_code_block#apply_highlighting()'
    execute 'autocmd TextChanged,TextChangedI ' . extensions . ' call better_code_block#apply_highlighting()'
    autocmd ColorScheme * call better_code_block#setup_highlight_style()
  augroup END
  
  command! BetterCodeBlockRefresh call better_code_block#apply_highlighting()
  command! BetterCodeBlockClear call better_code_block#clear_highlights()
  command! BetterCodeBlockToggleDebug let g:better_code_block_debug = !g:better_code_block_debug | echo "Debug mode " . (g:better_code_block_debug ? "enabled" : "disabled")
  command! -nargs=1 -complete=customlist,better_code_block#complete_styles BetterCodeBlockStyle call better_code_block#change_highlight_style(<q-args>)
  command! BetterCodeBlockToggleLineNumbers call better_code_block#toggle_line_numbers()
  command! -nargs=+ BetterCodeBlockRegisterStyle call better_code_block#register_custom_style(<f-args>)
endfunction

call s:SetupPlugin()

if expand('%:e') =~ join(g:better_code_block_extensions, '\|')
  call better_code_block#apply_highlighting()
endif

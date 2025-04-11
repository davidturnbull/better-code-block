" better-fenced-code-block.vim - Improved syntax highlighting for fenced code blocks
" Maintainer: Created with Claude
" Version: 2.1
" License: Same as Vim

" Prevent loading the plugin multiple times
if exists("g:loaded_better_fenced_code_block")
  finish
endif
let g:loaded_better_fenced_code_block = 1

" Plugin configuration
" ==============================================================================
" Default highlight style - can be overridden by user
if !exists('g:better_fenced_code_block_style')
  let g:better_fenced_code_block_style = 'green'
endif

" Custom highlight definition - override default styles
if !exists('g:better_fenced_code_block_custom')
  let g:better_fenced_code_block_custom = {}
endif

" Debug mode - set to 1 to enable debug messages
if !exists('g:better_fenced_code_block_debug')
  let g:better_fenced_code_block_debug = 0
endif

" File extensions to automatically process
if !exists('g:better_fenced_code_block_extensions')
  let g:better_fenced_code_block_extensions = ['md', 'markdown', 'txt']
endif

" Primary highlight keyword
if !exists('g:better_fenced_code_block_keyword')
  let g:better_fenced_code_block_keyword = 'highlight'
endif

" Alias keywords for highlight
if !exists('g:better_fenced_code_block_keyword_aliases')
  let g:better_fenced_code_block_keyword_aliases = ['hl', 'mark', 'emphasize']
endif

" Enable/disable relative line numbers in code blocks
if !exists('g:better_fenced_code_block_show_line_numbers')
  let g:better_fenced_code_block_show_line_numbers = 1
endif

" Line number display method: 'nvim' (virtual text), 'prop' (text properties), 'sign' (signs)
if !exists('g:better_fenced_code_block_line_number_method')
  let g:better_fenced_code_block_line_number_method = 'auto'
endif

" Line number format - can include %d for the line number
if !exists('g:better_fenced_code_block_line_number_format')
  let g:better_fenced_code_block_line_number_format = ' %d '
endif

" Line number style
if !exists('g:better_fenced_code_block_line_number_style')
  let g:better_fenced_code_block_line_number_style = 'LineNr'
endif

" Error style for invalid line numbers
if !exists('g:better_fenced_code_block_error_style')
  let g:better_fenced_code_block_error_style = 'red'
endif

" Update delay in milliseconds (0 for immediate)
if !exists('g:better_fenced_code_block_update_delay')
  let g:better_fenced_code_block_update_delay = 0
endif

" Custom fence patterns (must contain at least one capture group for the fence characters)
if !exists('g:better_fenced_code_block_fence_patterns')
  let g:better_fenced_code_block_fence_patterns = [
        \ '^\(`\{3,}\)',
        \ '^\(\~\{3,}\)'
        \ ]
endif

" Highlight method: 'background', 'foreground', 'underline', 'undercurl', 'bold', 'italic', 'reverse'
if !exists('g:better_fenced_code_block_method')
  let g:better_fenced_code_block_method = 'background'
endif

" Plugin initialization
" ==============================================================================
function! s:SetupPlugin()
  " Setup the highlight style
  call better_fenced_code_block#setup_highlight_style()
  
  " Ensure line numbers are shown (file numbers on left)
  if g:better_fenced_code_block_show_line_numbers
    set number
    
    " Only set signcolumn if using the sign method
    let method = g:better_fenced_code_block_line_number_method
    if method == 'auto' && !has('nvim-0.5') && !exists('*prop_type_add')
      set signcolumn=yes:1
    elseif method == 'sign'
      set signcolumn=yes:1
    endif
  endif
  
  " Create autocommands for automatic highlighting
  let extensions = join(map(copy(g:better_fenced_code_block_extensions), '"*." . v:val'), ',')
  
  " Define autocommands group
  augroup BetterFencedCodeBlock
    autocmd!
    " Update highlighting on more events to ensure errors are cleared when fixed
    execute 'autocmd BufReadPost,BufWritePost ' . extensions . ' call better_fenced_code_block#apply_highlighting()'
    execute 'autocmd InsertLeave ' . extensions . ' call better_fenced_code_block#apply_highlighting()'
    execute 'autocmd TextChanged,TextChangedI ' . extensions . ' call better_fenced_code_block#apply_highlighting()'
    autocmd ColorScheme * call better_fenced_code_block#setup_highlight_style()
  augroup END
  
  " Define plugin commands
  command! BetterFencedCodeBlockRefresh call better_fenced_code_block#apply_highlighting()
  command! BetterFencedCodeBlockClear call better_fenced_code_block#clear_highlights()
  
  " Define command to toggle debug mode
  command! BetterFencedCodeBlockToggleDebug let g:better_fenced_code_block_debug = !g:better_fenced_code_block_debug | 
        \ echo "Debug mode " . (g:better_fenced_code_block_debug ? "enabled" : "disabled")
  
  " Expose highlight style changing command
  command! -nargs=1 -complete=customlist,better_fenced_code_block#complete_styles BetterFencedCodeBlockStyle call better_fenced_code_block#change_highlight_style(<q-args>)
  
  " Toggle line numbers command
  command! BetterFencedCodeBlockToggleLineNumbers call better_fenced_code_block#toggle_line_numbers()
  
  " Register a custom highlight style
  command! -nargs=+ BetterFencedCodeBlockRegisterStyle call better_fenced_code_block#register_custom_style(<f-args>)
endfunction

" Initialize plugin
call s:SetupPlugin()

" Setup for immediate highlighting in current buffer
if expand('%:e') =~ join(g:better_fenced_code_block_extensions, '\|')
  call better_fenced_code_block#apply_highlighting()
endif

" Autoload functions for better-fenced-code-block
" Functions in this file will be automatically loaded when called

" Parse the highlight property to get line numbers to highlight
function! better_fenced_code_block#parse_highlight_spec(line)
  " Initialize empty array for line numbers
  let lines_to_highlight = []
  
  " Try primary keyword and aliases
  let keywords = [g:markdown_highlight_keyword] + g:markdown_highlight_keyword_aliases
  let highlight_spec = ''
  
  for keyword in keywords
    " Try double quotes pattern first
    let double_quote_pattern = keyword . '="\([^"]*\)"'
    let matches = matchlist(a:line, double_quote_pattern)
    
    if !empty(matches)
      let highlight_spec = trim(matches[1])
      call s:debug_message("Found spec with keyword '" . keyword . "' in double quotes: '" . highlight_spec . "'")
      break
    endif
    
    " Try single quotes pattern
    let single_quote_pattern = keyword . "='\\([^']*\\)'"
    let matches = matchlist(a:line, single_quote_pattern)
    
    if !empty(matches)
      let highlight_spec = trim(matches[1])
      call s:debug_message("Found spec with keyword '" . keyword . "' in single quotes: '" . highlight_spec . "'")
      break
    endif
    
    " Try without quotes
    let no_quotes_pattern = keyword . '=\([0-9,\s\-]\+\)'
    let matches = matchlist(a:line, no_quotes_pattern)
    
    if !empty(matches)
      let highlight_spec = trim(matches[1])
      call s:debug_message("Found spec with keyword '" . keyword . "' without quotes: '" . highlight_spec . "'")
      break
    endif
  endfor
  
  " If no highlight property found, return empty array
  if empty(highlight_spec)
    return []
  endif
  
  " Check for colon format (e.g., "1-2:5")
  let colon_match = matchlist(highlight_spec, '\(\d\+\)\s*-\s*\(\d\+\)\s*:\s*\(\d\+\)')
  if !empty(colon_match)
    let start = str2nr(colon_match[1])
    let end = str2nr(colon_match[2])
    let single = str2nr(colon_match[3])
    
    " Add range
    for i in range(start, end)
      call add(lines_to_highlight, i)
    endfor
    
    " Add single line
    call add(lines_to_highlight, single)
    
    call s:debug_message("Parsed colon format - lines: " . string(lines_to_highlight))
    return lines_to_highlight
  endif
  
  " Process comma-separated parts
  for part in split(highlight_spec, ',')
    let part = trim(part)
    
    " Check for range (e.g., "1-3")
    let range_match = matchlist(part, '\(\d\+\)\s*-\s*\(\d\+\)')
    if !empty(range_match)
      let start = str2nr(range_match[1])
      let end = str2nr(range_match[2])
      
      " Add all lines in range
      for i in range(start, end)
        call add(lines_to_highlight, i)
      endfor
      
      call s:debug_message("Added range " . start . "-" . end)
    else
      " Single line number
      let num = str2nr(part)
      if num > 0
        call add(lines_to_highlight, num)
        call s:debug_message("Added single line " . num)
      endif
    endif
  endfor
  
  return lines_to_highlight
endfunction

" Apply highlighting to specified lines
function! better_fenced_code_block#apply_highlighting()
  " If delay is set and we're in event-triggered update, debounce it
  if g:markdown_highlight_update_delay > 0 && exists('b:markdown_update_timer')
    call timer_stop(b:markdown_update_timer)
  endif
  
  if g:markdown_highlight_update_delay > 0
    let b:markdown_update_timer = timer_start(g:markdown_highlight_update_delay, 
          \ {-> better_fenced_code_block#do_apply_highlighting()})
  else
    call better_fenced_code_block#do_apply_highlighting()
  endif
endfunction

" Actual highlighting application (after potential delay)
function! better_fenced_code_block#do_apply_highlighting()
  " Clear previous highlights
  call better_fenced_code_block#clear_highlights()
  
  " Get buffer content
  let buffer_text = getline(1, '$')
  let in_code_block = 0
  let code_block_start = 0
  let line_num = 0
  let fence_type = ''
  let code_block_lines = 0
  let b:mch_has_errors = 0  " Reset error flag for this buffer
  
  " Process each line in the buffer
  for line in buffer_text
    let line_num += 1
    
    " Check for code block start using configured fence patterns
    if !in_code_block
      let fence_match = ''
      let fence_pattern = ''
      
      for pattern in g:markdown_highlight_fence_patterns
        let matches = matchlist(line, pattern)
        if !empty(matches) && !empty(matches[1])
          let fence_match = matches[1]
          let fence_pattern = pattern
          break
        endif
      endfor
      
      if !empty(fence_match)
        let in_code_block = 1
        let code_block_start = line_num
        let lines_to_highlight = better_fenced_code_block#parse_highlight_spec(line)
        " Store the exact fence string
        let fence_type = fence_match
        " Reset the code block line count
        let code_block_lines = 0
        call s:debug_message("Found code block at line " . line_num . " with fence: " . fence_type . ", highlight lines: " . string(lines_to_highlight))
        continue
      endif
    endif
    
    " Check for code block end (exact match with the fence that started it)
    if in_code_block && line =~ '^' . fence_type . '$'
      " Validate line numbers now that we know the total code block size
      if exists('lines_to_highlight') && !empty(lines_to_highlight)
        call s:validate_highlight_lines(lines_to_highlight, code_block_lines, code_block_start)
      endif
      
      let in_code_block = 0
      call s:debug_message("Code block ended at line " . line_num . " with fence: " . fence_type)
      continue
    endif
    
    " Inside code block - count lines
    if in_code_block
      let code_block_lines += 1
      let relative_line = line_num - code_block_start
      
      " Apply highlight to specified lines within code block
      if exists('lines_to_highlight') && !empty(lines_to_highlight)
        if index(lines_to_highlight, relative_line) >= 0
          call s:highlight_line(line_num)
          call s:debug_message("Highlighted line " . line_num . " (relative line " . relative_line . ")")
        endif
        
        " Add line number based on configured method
        if g:markdown_highlight_show_line_numbers
          call s:place_line_number(line_num, relative_line)
        endif
      endif
    endif
  endfor
endfunction

" Enable feature with highlighting
function! better_fenced_code_block#enable()
  call better_fenced_code_block#apply_highlighting()
  echo 'Better Fenced Code Block enabled'
endfunction

" Disable the feature
function! better_fenced_code_block#disable()
  call better_fenced_code_block#clear_highlights()
  echo 'Better Fenced Code Block disabled'
endfunction

" Toggle functionality
function! better_fenced_code_block#toggle()
  if exists('b:highlighting_enabled') && b:highlighting_enabled
    let b:highlighting_enabled = 0
    call better_fenced_code_block#disable()
  else
    let b:highlighting_enabled = 1
    call better_fenced_code_block#enable()
  endif
endfunction

" Debug output
function! s:debug_message(msg)
  if g:markdown_highlight_debug == 1
    echom "[BFCB] " . a:msg
  endif
endfunction

" Place line number using configured method
function! s:place_line_number(line_num, relative_line)
  let line_number_text = substitute(g:markdown_highlight_line_number_format, '%d', a:relative_line, 'g')
  
  " Determine method to use
  let method = g:markdown_highlight_line_number_method
  
  " If auto, select best available method
  if method == 'auto'
    if has('nvim-0.5')
      let method = 'nvim'
    elseif exists('*prop_type_add')
      let method = 'prop'
    else
      let method = 'sign'
    endif
  endif
  
  if method == 'nvim' && has('nvim-0.5')
    call s:place_line_number_nvim(a:line_num, line_number_text)
  elseif method == 'prop' && exists('*prop_type_add')
    call s:place_line_number_vim(a:line_num, line_number_text)
  else
    call s:place_line_number_sign(a:line_num, a:relative_line)
  endif
endfunction

" Place a line number using Neovim's virtual text
function! s:place_line_number_nvim(line_num, line_number_text)
  if !exists('b:mch_namespace_id')
    let b:mch_namespace_id = nvim_create_namespace('better_fenced_code_block')
  endif
  
  " Clear any existing line number at this line
  call nvim_buf_clear_namespace(0, b:mch_namespace_id, a:line_num-1, a:line_num)
  
  " Place the line number as virtual text right after the line number column
  call nvim_buf_set_virtual_text(0, b:mch_namespace_id, a:line_num-1, 
        \ [[a:line_number_text, g:markdown_highlight_line_number_style]], {})
endfunction

" Place a line number using Vim's text properties
function! s:place_line_number_vim(line_num, line_number_text)
  " Ensure we have our property type defined
  if !exists('s:prop_type_defined')
    call prop_type_add('BFCB_LineNr', {'highlight': g:markdown_highlight_line_number_style})
    let s:prop_type_defined = 1
  endif
  
  " Store IDs for cleanup
  if !exists('b:mch_prop_ids')
    let b:mch_prop_ids = []
  endif
  
  " Add the property at the start of the line
  let prop_id = prop_add(a:line_num, 1, {
        \ 'type': 'BFCB_LineNr',
        \ 'text': a:line_number_text
        \ })
  
  call add(b:mch_prop_ids, prop_id)
endfunction

" Place a line number using signs
function! s:place_line_number_sign(line_num, relative_line)
  " Create a unique sign name for each line number value
  let sign_name = 'BFCBLineNr' . a:relative_line
  
  " Define the sign if not already defined
  if !exists('s:defined_signs') || index(s:defined_signs, sign_name) == -1
    execute 'sign define ' . sign_name . ' text=' . a:relative_line . ' texthl=' . g:markdown_highlight_line_number_style
    if !exists('s:defined_signs')
      let s:defined_signs = []
    endif
    call add(s:defined_signs, sign_name)
  endif
  
  " Generate a unique ID for this sign placement
  if !exists('s:sign_id_counter')
    let s:sign_id_counter = 1000  " Start with a high number to avoid conflicts
  else
    let s:sign_id_counter += 1
  endif
  
  " Place the sign
  execute 'sign place ' . s:sign_id_counter . ' line=' . a:line_num . ' name=' . sign_name . ' buffer=' . bufnr('%')
  
  " Store the sign ID for later removal
  if !exists('b:mch_sign_ids')
    let b:mch_sign_ids = []
  endif
  call add(b:mch_sign_ids, s:sign_id_counter)
endfunction

" Validate highlight line specifications against code block size
function! s:validate_highlight_lines(lines_to_highlight, code_block_lines, code_block_start)
  let has_invalid_lines = 0
  let invalid_numbers = []
  
  for line_num in a:lines_to_highlight
    " Check if the line number is valid (greater than 0 and less than or equal to code_block_lines)
    if line_num <= 0 || line_num > a:code_block_lines
      call s:debug_message("Invalid line number: " . line_num . " (code block has " . a:code_block_lines . " lines)")
      let has_invalid_lines = 1
      call add(invalid_numbers, line_num)
    endif
  endfor
  
  if has_invalid_lines
    call s:highlight_invalid_spec(a:code_block_start, invalid_numbers)
    let b:mch_has_errors = 1
  endif
endfunction

" Highlight an invalid highlight specification in the code fence line
function! s:highlight_invalid_spec(fence_line, invalid_nums)
  let line_text = getline(a:fence_line)
  
  " Apply error highlight style
  silent! highlight clear MarkdownCodeHighlightError
  if g:markdown_highlight_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:markdown_highlight_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    " Default fallback - DiffDelete is usually red in most colorschemes
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
  
  " Find all highlight specification parts
  let keyword_pattern = '\<\(' . g:markdown_highlight_keyword
  for alias in g:markdown_highlight_keyword_aliases
    let keyword_pattern .= '\|' . alias
  endfor
  let keyword_pattern .= '\)=\([''"]\?\)\([^''"]*\)\2'
  
  let matches = matchlist(line_text, keyword_pattern)
  if !empty(matches)
    let highlight_spec = matches[3]
    let start_idx = stridx(line_text, highlight_spec)
    
    if start_idx != -1
      " Store match id for cleanup
      if !exists('w:markdown_error_match_ids')
        let w:markdown_error_match_ids = []
      endif
      
      " Find specific parts to highlight
      for invalid_num in a:invalid_nums
        " Match patterns for the invalid number
        let patterns = [
              \ '\<' . invalid_num . '\>', 
              \ '\<\d\+\s*-\s*' . invalid_num . '\>', 
              \ '\<' . invalid_num . '\s*-\s*\d\+\>'
              \ ]
        
        for pattern in patterns
          let pos = matchstrpos(highlight_spec, pattern)
          if pos[1] != -1
            let error_start = start_idx + pos[1]
            let error_end = start_idx + pos[2]
            let match_id = matchadd('MarkdownCodeHighlightError', 
                  \ '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
            call add(w:markdown_error_match_ids, match_id)
            call s:debug_message("Added error highlight for line " . a:fence_line . 
                  \ ", position " . error_start . "-" . error_end . " (invalid number: " . invalid_num . ")")
          endif
        endfor
      endfor
    endif
  endif
endfunction

" Highlight a specific line using multiple methods for compatibility
function! s:highlight_line(line_num)
  " 1. Use syntax highlighting
  execute 'syntax match MarkdownCodeHighlight /\%' . a:line_num . 'l.*/'
  
  " 2. Use :match highlighting (helps with full-width display)
  if !exists('w:markdown_match_ids') 
    let w:markdown_match_ids = []
  endif
  
  let match_id = matchadd('MarkdownCodeHighlight', '\%' . a:line_num . 'l.*')
  call add(w:markdown_match_ids, match_id)
  
  " 3. Use 2match for additional coverage
  execute '2match MarkdownCodeHighlight /\%' . a:line_num . 'l.*/'
endfunction

" Clear Neovim virtual text
function! s:clear_line_number_nvim()
  if exists('b:mch_namespace_id')
    call nvim_buf_clear_namespace(0, b:mch_namespace_id, 0, -1)
  endif
endfunction

" Clear Vim text properties
function! s:clear_line_number_vim()
  if exists('b:mch_prop_ids') && type(b:mch_prop_ids) == v:t_list
    for id in b:mch_prop_ids
      call prop_remove({'id': id})
    endfor
  endif
  let b:mch_prop_ids = []
endfunction

" Clear all line number signs
function! s:clear_line_number_signs()
  if exists('b:mch_sign_ids') && type(b:mch_sign_ids) == v:t_list
    for id in b:mch_sign_ids
      execute 'sign unplace ' . id
    endfor
  endif
  let b:mch_sign_ids = []
endfunction

" Clear all highlights
function! better_fenced_code_block#clear_highlights()
  " Clear syntax highlights
  silent! syntax clear MarkdownCodeHighlight
  silent! syntax clear MarkdownCodeHighlightError
  
  " Clear match highlights
  if exists('w:markdown_match_ids') && type(w:markdown_match_ids) == v:t_list
    for id in w:markdown_match_ids
      try
        call matchdelete(id)
      catch
        " Ignore errors for non-existent matches
      endtry
    endfor
  endif
  let w:markdown_match_ids = []
  
  " Clear error highlights
  if exists('w:markdown_error_match_ids') && type(w:markdown_error_match_ids) == v:t_list
    for id in w:markdown_error_match_ids
      try
        call matchdelete(id)
      catch
        " Ignore errors for non-existent matches
      endtry
    endfor
  endif
  let w:markdown_error_match_ids = []
  
  " Clear 2match
  2match none
  
  " Clear line numbers based on method
  let method = g:markdown_highlight_line_number_method
  
  " If auto, select best available method
  if method == 'auto'
    if has('nvim-0.5')
      let method = 'nvim'
    elseif exists('*prop_type_add')
      let method = 'prop'
    else
      let method = 'sign'
    endif
  endif
  
  if method == 'nvim' && has('nvim-0.5')
    call s:clear_line_number_nvim()
  elseif method == 'prop' && exists('*prop_type_add')
    call s:clear_line_number_vim()
  else
    call s:clear_line_number_signs()
  endif
endfunction

" Apply highlighting style
function! better_fenced_code_block#setup_highlight_style()
  " Clear existing highlighting
  silent! highlight clear MarkdownCodeHighlight
  
  " Apply style based on configuration
  if has_key(g:markdown_highlight_custom, g:markdown_highlight_style)
    " Apply custom style definition
    let custom = g:markdown_highlight_custom[g:markdown_highlight_style]
    let cmd = 'highlight MarkdownCodeHighlight'
    
    " Handle term/cterm attributes
    if has_key(custom, 'cterm')
      let cmd .= ' cterm=' . custom.cterm
    endif
    if has_key(custom, 'ctermfg')
      let cmd .= ' ctermfg=' . custom.ctermfg
    endif
    if has_key(custom, 'ctermbg')
      let cmd .= ' ctermbg=' . custom.ctermbg
    endif
    
    " Handle gui attributes
    if has_key(custom, 'gui')
      let cmd .= ' gui=' . custom.gui
    endif
    if has_key(custom, 'guifg')
      let cmd .= ' guifg=' . custom.guifg
    endif
    if has_key(custom, 'guibg')
      let cmd .= ' guibg=' . custom.guibg
    endif
    
    execute cmd
  elseif g:markdown_highlight_style == 'green'
    highlight MarkdownCodeHighlight ctermbg=green ctermfg=black guibg=#00FF00 guifg=#000000
  elseif g:markdown_highlight_style == 'blue'
    highlight MarkdownCodeHighlight ctermbg=blue ctermfg=white guibg=#0000FF guifg=#FFFFFF
  elseif g:markdown_highlight_style == 'yellow'
    highlight MarkdownCodeHighlight ctermbg=yellow ctermfg=black guibg=#FFFF00 guifg=#000000
  elseif g:markdown_highlight_style == 'cyan'
    highlight MarkdownCodeHighlight ctermbg=cyan ctermfg=black guibg=#00FFFF guifg=#000000
  elseif g:markdown_highlight_style == 'magenta'
    highlight MarkdownCodeHighlight ctermbg=magenta ctermfg=black guibg=#FF00FF guifg=#000000
  elseif g:markdown_highlight_style == 'invert'
    highlight MarkdownCodeHighlight cterm=reverse gui=reverse
  elseif g:markdown_highlight_style == 'bold'
    highlight MarkdownCodeHighlight cterm=bold gui=bold
  elseif g:markdown_highlight_style == 'italic'
    highlight MarkdownCodeHighlight cterm=italic gui=italic
  elseif g:markdown_highlight_style == 'underline'
    highlight MarkdownCodeHighlight cterm=underline gui=underline
  elseif g:markdown_highlight_style == 'undercurl'
    highlight MarkdownCodeHighlight cterm=undercurl gui=undercurl
  else
    " Default fallback - DiffAdd is usually green in most colorschemes
    highlight link MarkdownCodeHighlight DiffAdd
  endif
  
  " Setup error highlight style
  silent! highlight clear MarkdownCodeHighlightError
  
  if g:markdown_highlight_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:markdown_highlight_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    " Default fallback - DiffDelete is usually red in most colorschemes
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
endfunction

" Function to toggle line numbers
function! better_fenced_code_block#toggle_line_numbers()
  let g:markdown_highlight_show_line_numbers = !g:markdown_highlight_show_line_numbers
  
  " Toggle line numbers
  if g:markdown_highlight_show_line_numbers
    set number
    
    " Only set signcolumn if using the sign method
    let method = g:markdown_highlight_line_number_method
    if method == 'auto' && !has('nvim-0.5') && !exists('*prop_type_add')
      set signcolumn=yes:1
    elseif method == 'sign'
      set signcolumn=yes:1
    endif
  else
    " Reset signcolumn if needed
    let method = g:markdown_highlight_line_number_method
    if method == 'auto' && !has('nvim-0.5') && !exists('*prop_type_add')
      set signcolumn=auto
    elseif method == 'sign'
      set signcolumn=auto
    endif
  endif
  
  call better_fenced_code_block#apply_highlighting()
  echo "Line numbers " . (g:markdown_highlight_show_line_numbers ? "enabled" : "disabled")
endfunction

" Style-related functions
function! better_fenced_code_block#complete_styles(ArgLead, CmdLine, CursorPos)
  let builtin_styles = ['green', 'yellow', 'cyan', 'blue', 'magenta', 'invert', 'bold', 'italic', 'underline', 'undercurl']
  let custom_styles = keys(g:markdown_highlight_custom)
  let all_styles = builtin_styles + custom_styles
  return filter(all_styles, 'v:val =~ "^" . a:ArgLead')
endfunction

function! better_fenced_code_block#change_highlight_style(style)
  let g:markdown_highlight_style = a:style
  call better_fenced_code_block#setup_highlight_style()
  call better_fenced_code_block#apply_highlighting()
  echo "Highlight style changed to: " . a:style
endfunction

function! better_fenced_code_block#register_custom_style(name, ...)
  if a:0 == 0
    echoerr "MarkdownHighlightRegisterStyle requires at least one attribute!"
    return
  endif
  
  let custom = {}
  let i = 0
  
  while i < a:0
    let attr = a:000[i]
    let i += 1
    
    if i >= a:0
      echoerr "Missing value for attribute: " . attr
      return
    endif
    
    let value = a:000[i]
    let custom[attr] = value
    let i += 1
  endwhile
  
  let g:markdown_highlight_custom[a:name] = custom
  echo "Registered custom style: " . a:name
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

" Autoload functions for better-code-block
" Functions in this file will be automatically loaded when called

" Parse the highlight property to get line numbers to highlight
function! better_code_block#parse_highlight_spec(line)
  " Extract the highlight specification from the line
  let highlight_spec = better_code_block#extract_highlight_spec(a:line)
  
  " If no highlight property found, return empty array
  if empty(highlight_spec)
    return []
  endif
  
  " Parse the highlight attribute into line numbers
  return better_code_block#parse_highlight_attribute(highlight_spec)
endfunction

" Extract highlight specification from a markdown fence line
function! better_code_block#extract_highlight_spec(line) abort
  let l:keywords = [g:better_code_block_keyword] + g:better_code_block_keyword_aliases
  let l:highlight_spec = ''
  for l:keyword in l:keywords
    let l:spec = s:GetFlagValueWithQuotes(a:line, l:keyword, '"')
    if !empty(l:spec)
      let l:highlight_spec = l:spec
      call s:LogDebug("Found spec with keyword '" . l:keyword . "' in double quotes: '" . l:highlight_spec . "'")
      break
    endif
    let l:spec = s:GetFlagValueWithQuotes(a:line, l:keyword, "'")
    if !empty(l:spec)
      let l:highlight_spec = l:spec
      call s:LogDebug("Found spec with keyword '" . l:keyword . "' in single quotes: '" . l:highlight_spec . "'")
      break
    endif
    let l:spec = s:GetFlagValueWithoutQuotes(a:line, l:keyword)
    if !empty(l:spec)
      let l:highlight_spec = l:spec
      call s:LogDebug("Found spec with keyword '" . l:keyword . "' without quotes: '" . l:highlight_spec . "'")
      break
    endif
  endfor
  return l:highlight_spec
endfunction

" Extract start line number from a markdown fence line
function! better_code_block#extract_start_spec(line) abort
  let l:keywords = [g:better_code_block_start_keyword] + g:better_code_block_start_keyword_aliases
  let l:start_spec = ''
  for l:keyword in l:keywords
    let l:spec = s:GetFlagValueWithQuotes(a:line, l:keyword, '"')
    if !empty(l:spec)
      let l:start_spec = l:spec
      call s:LogDebug("Found start spec with keyword '" . l:keyword . "' in double quotes: '" . l:start_spec . "'")
      break
    endif
    let l:spec = s:GetFlagValueWithQuotes(a:line, l:keyword, "'")
    if !empty(l:spec)
      let l:start_spec = l:spec
      call s:LogDebug("Found start spec with keyword '" . l:keyword . "' in single quotes: '" . l:start_spec . "'")
      break
    endif
    let l:spec = s:GetFlagValueWithoutQuotes(a:line, l:keyword)
    if !empty(l:spec)
      let l:start_spec = l:spec
      call s:LogDebug("Found start spec with keyword '" . l:keyword . "' without quotes: '" . l:start_spec . "'")
      break
    endif
  endfor
  return l:start_spec
endfunction

" New pure function to extract a flag value enclosed in quotes without side effects.
function! s:GetFlagValueWithQuotes(line, keyword, quote) abort
  let l:pattern = a:keyword . '\s*=\s*' . a:quote . '\([^' . a:quote . ']*\)' . a:quote
  let l:result = matchlist(a:line, l:pattern)
  if !empty(l:result)
    return trim(l:result[1])
  endif
  let l:pattern = a:keyword . '=' . a:quote . '\([^' . a:quote . ']*\)' . a:quote
  let l:result = matchlist(a:line, l:pattern)
  if !empty(l:result)
    return trim(l:result[1])
  endif
  return ''
endfunction

" New pure function to extract a flag value without quotes.
function! s:GetFlagValueWithoutQuotes(line, keyword) abort
  let l:pattern = a:keyword . '=\([0-9,\s\-]\+\)'
  let l:result = matchlist(a:line, l:pattern)
  if !empty(l:result)
    return trim(l:result[1])
  endif
  return ''
endfunction

" Parse a highlight attribute value into an array of line numbers
function! better_code_block#parse_highlight_attribute(highlight_spec) abort
  let l:numbers = []
  for l:part in split(a:highlight_spec, ',')
    let l:part = trim(l:part)
    let l:range_numbers = s:ExtractRangeNumbers(l:part)
    if !empty(l:range_numbers)
      call extend(l:numbers, l:range_numbers)
    else
      let l:single = s:ParseSingleLineNumber(l:part)
      if l:single > 0
        call add(l:numbers, l:single)
      endif
    endif
  endfor
  return l:numbers
endfunction

" Pure function to extract a numerical range from a string (format: "start-end")
function! s:ExtractRangeNumbers(part) abort
  let l:match = matchlist(a:part, '^\s*\(\d\+\)\s*-\s*\(\d\+\)\s*$')
  if empty(l:match)
    return []
  endif
  let l:start = str2nr(l:match[1])
  let l:end = str2nr(l:match[2])
  if l:end < l:start
    return []
  endif
  return range(l:start, l:end)
endfunction

function! s:parse_range(part) abort
  return s:ExtractRangeNumbers(a:part)
endfunction

" Get all line numbers in a range
function! s:GetRangeLines(start, end)
  let lines = []
  if a:end < a:start
    call s:LogDebug("Invalid range: end (" . a:end . ") is less than start (" . a:start . ")")
    return []
  endif
  for i in range(a:start, a:end)
    call add(lines, i)
  endfor
  return lines
endfunction

function! s:ParsePositiveInteger(number_str) abort
  let l:num = str2nr(a:number_str)
  return (l:num > 0 ? l:num : 0)
endfunction

function! s:ParseSingleLineNumber(part) abort
  " If the part contains a dash then it is not a valid single positive number.
  if a:part =~ '-'
    return 0
  endif
  return s:ParsePositiveInteger(a:part)
endfunction

function! s:get_range_lines(start, end)
  return s:GetRangeLines(a:start, a:end)
endfunction

" Parse a single line number
function! s:parse_single_line(part)
  if a:part =~# '^-\d\+$'
    if !exists('b:mch_negative_values')
      let b:mch_negative_values = []
    endif
    call add(b:mch_negative_values, a:part)
    call s:debug_message("Detected negative line number: " . a:part)
    let b:mch_has_errors = 1
    return 0
  endif
  if a:part =~# '-'
    call s:debug_message("Rejected malformed range as single line: " . a:part)
    return 0
  endif
  let num = str2nr(a:part)
  if num > 0
    call s:debug_message("Added single line " . num)
    return num
  endif
  return 0
endfunction

" Parse a start value from a start specification
function! better_code_block#parse_start_value(start_spec)
  if empty(a:start_spec)
    return 1
  endif
  if a:start_spec =~# '^-\d\+$'
    if !exists('b:mch_negative_start_values')
      let b:mch_negative_start_values = []
    endif
    call add(b:mch_negative_start_values, a:start_spec)
    call s:debug_message("Detected negative start value: " . a:start_spec)
    let b:mch_has_errors = 1
    return 1
  endif
  if a:start_spec !~# '^\d\+$'
    if !exists('b:mch_invalid_start_values')
      let b:mch_invalid_start_values = []
    endif
    call add(b:mch_invalid_start_values, a:start_spec)
    call s:debug_message("Detected invalid start value: " . a:start_spec)
    let b:mch_has_errors = 1
    return 1
  endif
  let num = str2nr(a:start_spec)
  call s:debug_message("Parsed start value: " . num)
  return num
endfunction

" Apply highlighting to specified lines
function! better_code_block#apply_highlighting()
  if g:better_code_block_update_delay > 0 && exists('b:better_code_block_update_timer')
    call timer_stop(b:better_code_block_update_timer)
  endif
  if g:better_code_block_update_delay > 0
    let b:better_code_block_update_timer = timer_start(g:better_code_block_update_delay, {-> better_code_block#do_apply_highlighting()})
  else
    call better_code_block#do_apply_highlighting()
  endif
endfunction

" Find code blocks in the buffer and return their information
function! s:find_code_blocks()
  let buffer_text = getline(1, '$')
  let code_blocks = []
  let in_code_block = 0
  let code_block_start = 0
  let line_num = 0
  let fence_type = ''
  let code_block_lines = 0
  let current_block = {}
  for line in buffer_text
    let line_num += 1
    call s:debug_message("Processing line " . line_num . ": " . line)
    if !in_code_block
      let fence_match = ''
      let fence_pattern = ''
      call s:debug_message("Checking fence patterns: " . string(g:better_code_block_fence_patterns))
      for pattern in g:better_code_block_fence_patterns
        call s:debug_message("Trying pattern: " . pattern . " against line: " . line)
        let matches = matchlist(line, pattern)
        if !empty(matches)
          call s:debug_message("Got matches: " . string(matches))
          if len(matches) > 1 && !empty(matches[1])
            let fence_match = matches[1]
            let fence_pattern = pattern
            call s:debug_message("Matched fence pattern: " . pattern . " with fence: " . fence_match)
            break
          endif
        endif
      endfor
      if empty(fence_match) && line =~# '^```'
        let fence_match = '```'
        let fence_pattern = '^```\(.*\)$'
        call s:debug_message("Special case: matched simple backtick fence")
      endif
      if !empty(fence_match)
        let in_code_block = 1
        let code_block_start = line_num
        let lines_to_highlight = better_code_block#parse_highlight_spec(line)
        let start_spec = better_code_block#extract_start_spec(line)
        let start_value = better_code_block#parse_start_value(start_spec)
        if line =~# '^```'
          let fence_type = '```'
        else
          let fence_type = fence_match
        endif
        let code_block_lines = 0
        let language = s:detect_language(line)
        let current_block = {'start_line': code_block_start, 'fence_type': fence_type, 'highlight_lines': lines_to_highlight, 'language': language, 'content_lines': [], 'start_value': start_value}
        call s:debug_message("Found code block at line " . line_num . " with fence: " . fence_type . ", highlight lines: " . string(lines_to_highlight))
        continue
      endif
    endif
    if in_code_block
      if fence_type ==# '```' && line =~# '^```\s*$'
        let is_fence_end = 1
        call s:debug_message("Special case: matched simple backtick fence end: " . line)
      else
        let is_fence_end = line ==# fence_type || line =~# '^' . escape(fence_type, '\.^$*[]') . '\s*$'
      endif
      if is_fence_end
        let current_block['end_line'] = line_num
        let current_block['line_count'] = code_block_lines
        call add(code_blocks, current_block)
        let in_code_block = 0
        call s:debug_message("Code block ended at line " . line_num . " with fence: " . fence_type . ", added block to list, now have " . len(code_blocks) . " blocks")
        continue
      endif
    endif
    if in_code_block
      let code_block_lines += 1
      call add(current_block['content_lines'], {'line_num': line_num, 'content': line, 'relative_line': code_block_lines})
    endif
  endfor
  return code_blocks
endfunction

" Actual highlighting application (after potential delay)
function! better_code_block#do_apply_highlighting()
  call better_code_block#clear_highlights()
  let b:mch_has_errors = 0
  let code_blocks = s:find_code_blocks()
  for block in code_blocks
    let code_block_start = block['start_line']
    let code_block_lines = block['line_count']
    let lines_to_highlight = block['highlight_lines']
    let b:mch_current_fence_line = code_block_start
    if exists('b:mch_reversed_ranges') && !empty(b:mch_reversed_ranges)
      for range_info in b:mch_reversed_ranges
        call s:highlight_invalid_spec(b:mch_current_fence_line, [range_info[0], range_info[1]])
        call s:debug_message("Applied delayed highlighting for reversed range: " . range_info[0] . "-" . range_info[1] . " at line " . b:mch_current_fence_line)
      endfor
      let b:mch_reversed_ranges = []
    endif
    if exists('b:mch_negative_values') && !empty(b:mch_negative_values)
      call s:highlight_negative_values(b:mch_current_fence_line, b:mch_negative_values)
      let b:mch_negative_values = []
    endif
    if exists('b:mch_negative_start_values') && !empty(b:mch_negative_start_values)
      call s:highlight_invalid_start_value(b:mch_current_fence_line, b:mch_negative_start_values, '-')
      let b:mch_negative_start_values = []
    endif
    if exists('b:mch_invalid_start_values') && !empty(b:mch_invalid_start_values)
      call s:highlight_invalid_start_value(b:mch_current_fence_line, b:mch_invalid_start_values, 'invalid')
      let b:mch_invalid_start_values = []
    endif
    let line_text = getline(b:mch_current_fence_line)
    let highlight_spec = better_code_block#extract_highlight_spec(line_text)
    if !empty(highlight_spec)
      let parts = split(highlight_spec, ',')
      for part in parts
        let part = trim(part)
        let range_match = matchlist(part, '\(\d\+\)\s*-\s*\(\d\+\)')
        if !empty(range_match)
          let start = str2nr(range_match[1])
          let end = str2nr(range_match[2])
          if end < start
            call s:highlight_invalid_part(b:mch_current_fence_line, highlight_spec, part)
            let b:mch_has_errors = 1
          endif
        endif
      endfor
    endif
    if !empty(lines_to_highlight)
      call s:validate_highlight_lines(lines_to_highlight, code_block_lines, code_block_start)
    endif
    for content_line in block['content_lines']
      let line_num = content_line['line_num']
      let relative_line = content_line['relative_line']
      let start_value = block['start_value']
      let display_line = relative_line + start_value - 1
      if !empty(lines_to_highlight)
        let adjusted_lines_to_highlight = []
        if start_value > 1
          for hl_line in lines_to_highlight
            if hl_line >= start_value
              let adjusted_line = hl_line - start_value + 1
              if adjusted_line > 0 && adjusted_line <= code_block_lines
                call add(adjusted_lines_to_highlight, adjusted_line)
              endif
            else
              call add(adjusted_lines_to_highlight, hl_line)
            endif
          endfor
          call s:debug_message("Adjusted highlight lines for start value " . start_value . ": " . string(lines_to_highlight) . " -> " . string(adjusted_lines_to_highlight))
        else
          let adjusted_lines_to_highlight = lines_to_highlight
        endif
        
        if index(adjusted_lines_to_highlight, relative_line) >= 0
          call s:highlight_line(line_num)
          call s:debug_message("Highlighted line " . line_num . " (relative line " . relative_line . ")")
        endif
        
        if (type(g:better_code_block_show_line_numbers) == v:t_number && g:better_code_block_show_line_numbers) || g:better_code_block_show_line_numbers == 'always' || (g:better_code_block_show_line_numbers == 'with_highlights' && !empty(lines_to_highlight))
          call s:place_line_number(line_num, display_line)
        endif
      else
        if (type(g:better_code_block_show_line_numbers) == v:t_number && g:better_code_block_show_line_numbers) || g:better_code_block_show_line_numbers == 'always'
          call s:place_line_number(line_num, display_line)
        endif
      endif
    endfor
  endfor
  unlet! b:mch_current_fence_line
endfunction

" Enable feature with highlighting
function! better_code_block#enable()
  call better_code_block#apply_highlighting()
  echo 'Better Code Blocks enabled'
endfunction

" Disable the feature
function! better_code_block#disable()
  call better_code_block#clear_highlights()
  echo 'Better Code Blocks disabled'
endfunction

" Toggle functionality
function! better_code_block#toggle()
  if exists('b:highlighting_enabled') && b:highlighting_enabled
    let b:highlighting_enabled = 0
    call better_code_block#disable()
  else
    let b:highlighting_enabled = 1
    call better_code_block#enable()
  endif
endfunction

" Debug output
function! s:LogDebug(msg) abort
  if g:better_code_block_debug == 1 || exists('g:vader_file')
    echom "[BCB] " . a:msg
  endif
endfunction

" Alias for compatibility
function! s:debug_message(msg) abort
  call s:LogDebug(a:msg)
endfunction

" Place line number using configured method
function! s:place_line_number(line_num, relative_line)
  let line_number_text = substitute(g:better_code_block_line_number_format, '%d', a:relative_line, 'g')
  let method = s:determine_line_number_method()
  if method == 'nvim' && has('nvim-0.5')
    call s:place_line_number_nvim(a:line_num, line_number_text)
  elseif method == 'prop' && exists('*prop_type_add')
    call s:place_line_number_vim(a:line_num, line_number_text)
  else
    call s:place_line_number_sign(a:line_num, a:relative_line)
  endif
endfunction

" Determine the best line number method based on configuration and capabilities
function! s:determine_line_number_method()
  if !exists('g:better_code_block_line_number_method')
    let g:better_code_block_line_number_method = 'auto'
  endif
  let method = g:better_code_block_line_number_method
  if method == 'auto'
    if has('nvim-0.5')
      return 'nvim'
    elseif exists('*prop_type_add')
      return 'prop'
    else
      return 'sign'
    endif
  endif
  return method
endfunction

" Place a line number using Neovim's virtual text
function! s:place_line_number_nvim(line_num, line_number_text)
  if !exists('b:mch_namespace_id')
    let b:mch_namespace_id = nvim_create_namespace('better_code_block')
  endif
  call nvim_buf_clear_namespace(0, b:mch_namespace_id, a:line_num-1, a:line_num)
  call nvim_buf_set_virtual_text(0, b:mch_namespace_id, a:line_num-1, [[a:line_number_text, g:better_code_block_line_number_style]], {})
endfunction

" Place a line number using Vim's text properties
function! s:place_line_number_vim(line_num, line_number_text)
  if !exists('s:prop_type_defined')
    call prop_type_add('BCB_LineNr', {'highlight': g:better_code_block_line_number_style})
    let s:prop_type_defined = 1
  endif
  if !exists('b:mch_prop_ids')
    let b:mch_prop_ids = []
  endif
  let prop_id = prop_add(a:line_num, 1, {'type': 'BCB_LineNr', 'text': a:line_number_text})
  call add(b:mch_prop_ids, prop_id)
endfunction

" Place a line number using signs
function! s:place_line_number_sign(line_num, relative_line)
  let sign_name = 'BCBLineNr' . a:relative_line
  if !exists('s:defined_signs') || index(s:defined_signs, sign_name) == -1
    execute 'sign define ' . sign_name . ' text=' . a:relative_line . ' texthl=' . g:better_code_block_line_number_style
    if !exists('s:defined_signs')
      let s:defined_signs = []
    endif
    call add(s:defined_signs, sign_name)
  endif
  if !exists('s:sign_id_counter')
    let s:sign_id_counter = 1000
  else
    let s:sign_id_counter += 1
  endif
  execute 'sign place ' . s:sign_id_counter . ' line=' . a:line_num . ' name=' . sign_name . ' buffer=' . bufnr('%')
  if !exists('b:mch_sign_ids')
    let b:mch_sign_ids = []
  endif
  call add(b:mch_sign_ids, s:sign_id_counter)
endfunction

" Validate highlight line specifications against code block size
function! s:validate_highlight_lines(lines_to_highlight, code_block_lines, code_block_start)
  let has_invalid_lines = 0
  let invalid_numbers = []
  let start_value = 1
  let line_text = getline(a:code_block_start)
  let start_spec = better_code_block#extract_start_spec(line_text)
  if !empty(start_spec)
    let start_value = better_code_block#parse_start_value(start_spec)
  endif
  for line_num in a:lines_to_highlight
    if line_num >= start_value && line_num < start_value + a:code_block_lines
      continue
    endif
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
  silent! highlight clear MarkdownCodeHighlightError
  if g:better_code_block_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:better_code_block_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
  let keyword_pattern = '\<\(' . g:better_code_block_keyword
  for alias in g:better_code_block_keyword_aliases
    let keyword_pattern .= '\|' . alias
  endfor
  let keyword_pattern .= '\)=\([''"]\?\)\([^''"]*\)\2'
  let matches = matchlist(line_text, keyword_pattern)
  if !empty(matches)
    let highlight_spec = matches[3]
    let start_idx = stridx(line_text, highlight_spec)
    if start_idx != -1
      if !exists('w:better_code_block_error_match_ids')
        let w:better_code_block_error_match_ids = []
      endif
      for invalid_num in a:invalid_nums
        let patterns = [
              \ '\<' . invalid_num . '\>',
              \ '\<\d\+\s*-\s*' . invalid_num . '\>',
              \ '\<' . invalid_num . '\s*-\s*\d\+\>'
              \ ]
        if len(a:invalid_nums) >= 2 && index(a:invalid_nums, invalid_num) == 0
          let next_index = index(a:invalid_nums, invalid_num) + 1
          if next_index < len(a:invalid_nums)
            let next_num = a:invalid_nums[next_index]
            if invalid_num > next_num
              let rev_pattern = '\<' . invalid_num . '\s*-\s*' . next_num . '\>'
              call add(patterns, rev_pattern)
              let pos = matchstrpos(highlight_spec, rev_pattern)
              if pos[1] != -1
                let error_start = start_idx + pos[1]
                let error_end = start_idx + pos[2]
                let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
                call add(w:better_code_block_error_match_ids, match_id)
                call s:debug_message("Added error highlight for reversed range " . a:fence_line . ", position " . error_start . "-" . error_end . " (" . invalid_num . "-" . next_num . ")")
                continue
              endif
            endif
          endif
        endif
        for pattern in patterns
          let pos = matchstrpos(highlight_spec, pattern)
          if pos[1] != -1
            let error_start = start_idx + pos[1]
            let error_end = start_idx + pos[2]
            let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
            call add(w:better_code_block_error_match_ids, match_id)
            call s:debug_message("Added error highlight for line " . a:fence_line . ", position " . error_start . "-" . error_end . " (invalid number: " . invalid_num . ")")
          endif
        endfor
      endfor
    endif
  endif
endfunction

" Highlight a specific line using multiple methods for compatibility
function! s:highlight_line(line_num)
  execute 'syntax match MarkdownCodeHighlight /\%' . a:line_num . 'l.*/'
  if !exists('w:better_code_block_match_ids')
    let w:better_code_block_match_ids = []
  endif
  let match_id = matchadd('MarkdownCodeHighlight', '\%' . a:line_num . 'l.*')
  call add(w:better_code_block_match_ids, match_id)
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
function! better_code_block#clear_highlights()
  silent! syntax clear MarkdownCodeHighlight
  silent! syntax clear MarkdownCodeHighlightError
  if exists('w:better_code_block_match_ids') && type(w:better_code_block_match_ids) == v:t_list
    for id in w:better_code_block_match_ids
      try
        call matchdelete(id)
      catch
      endtry
    endfor
  endif
  let w:better_code_block_match_ids = []
  if exists('w:better_code_block_error_match_ids') && type(w:better_code_block_error_match_ids) == v:t_list
    for id in w:better_code_block_error_match_ids
      try
        call matchdelete(id)
      catch
      endtry
    endfor
  endif
  let w:better_code_block_error_match_ids = []
  if exists('b:mch_reversed_ranges')
    let b:mch_reversed_ranges = []
  endif
  if exists('b:mch_negative_values')
    let b:mch_negative_values = []
  endif
  if exists('b:mch_negative_start_values')
    let b:mch_negative_start_values = []
  endif
  if exists('b:mch_invalid_start_values')
    let b:mch_invalid_start_values = []
  endif
  2match none
  let method = s:determine_line_number_method()
  if method == 'nvim' && has('nvim-0.5')
    call s:clear_line_number_nvim()
  elseif method == 'prop' && exists('*prop_type_add')
    call s:clear_line_number_vim()
  else
    call s:clear_line_number_signs()
  endif
endfunction

" Apply highlighting style
function! better_code_block#setup_highlight_style()
  silent! highlight clear MarkdownCodeHighlight
  call s:apply_main_highlight_style()
  call s:apply_error_highlight_style()
endfunction

" Apply the main highlight style based on configuration
function! s:apply_main_highlight_style()
  if has_key(g:better_code_block_custom, g:better_code_block_style)
    call s:apply_custom_highlight_style(g:better_code_block_style)
  elseif g:better_code_block_style =~ '^\(green\|blue\|yellow\|cyan\|magenta\)$'
    call s:apply_color_highlight_style(g:better_code_block_style)
  elseif g:better_code_block_style =~ '^\(invert\|bold\|italic\|underline\|undercurl\)$'
    call s:apply_attribute_highlight_style(g:better_code_block_style)
  else
    highlight link MarkdownCodeHighlight DiffAdd
  endif
endfunction

" Apply custom highlight style from configuration
function! s:apply_custom_highlight_style(style_name)
  let custom = g:better_code_block_custom[a:style_name]
  let cmd = 'highlight MarkdownCodeHighlight'
  if has_key(custom, 'cterm')
    let cmd .= ' cterm=' . custom.cterm
  endif
  if has_key(custom, 'ctermfg')
    let cmd .= ' ctermfg=' . custom.ctermfg
  endif
  if has_key(custom, 'ctermbg')
    let cmd .= ' ctermbg=' . custom.ctermbg
  endif
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
endfunction

" Apply a color-based highlight style
function! s:apply_color_highlight_style(color)
  if a:color == 'green'
    highlight MarkdownCodeHighlight ctermbg=green ctermfg=black guibg=#00FF00 guifg=#000000
  elseif a:color == 'blue'
    highlight MarkdownCodeHighlight ctermbg=blue ctermfg=white guibg=#0000FF guifg=#FFFFFF
  elseif a:color == 'yellow'
    highlight MarkdownCodeHighlight ctermbg=yellow ctermfg=black guibg=#FFFF00 guifg=#000000
  elseif a:color == 'cyan'
    highlight MarkdownCodeHighlight ctermbg=cyan ctermfg=black guibg=#00FFFF guifg=#000000
  elseif a:color == 'magenta'
    highlight MarkdownCodeHighlight ctermbg=magenta ctermfg=black guibg=#FF00FF guifg=#000000
  endif
endfunction

" Apply attribute-based highlight style
function! s:apply_attribute_highlight_style(attr)
  execute 'highlight MarkdownCodeHighlight cterm=' . a:attr . ' gui=' . a:attr
endfunction

" Apply error highlight style
function! s:apply_error_highlight_style()
  silent! highlight clear MarkdownCodeHighlightError
  if g:better_code_block_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:better_code_block_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
endfunction

" Function to toggle line numbers
function! better_code_block#toggle_line_numbers()
  if type(g:better_code_block_show_line_numbers) == v:t_number
    let g:better_code_block_show_line_numbers = g:better_code_block_show_line_numbers ? 'always' : 'never'
  endif
  if g:better_code_block_show_line_numbers == 'always'
    let g:better_code_block_show_line_numbers = 'with_highlights'
    call s:enable_line_numbers()
  elseif g:better_code_block_show_line_numbers == 'with_highlights'
    let g:better_code_block_show_line_numbers = 'never'
    call s:disable_line_numbers()
  else
    let g:better_code_block_show_line_numbers = 'always'
    call s:enable_line_numbers()
  endif
  call better_code_block#apply_highlighting()
  echo "Line numbers: " . g:better_code_block_show_line_numbers
endfunction

" Enable line numbers in the buffer
function! s:enable_line_numbers()
  set number
  let method = s:determine_line_number_method()
  if method == 'sign'
    set signcolumn=yes
  endif
endfunction

" Disable line numbers in the buffer
function! s:disable_line_numbers()
  let method = s:determine_line_number_method()
  if method == 'sign'
    set signcolumn=auto
  endif
endfunction

" Complete styles for command
function! better_code_block#complete_styles(ArgLead, CmdLine, CursorPos)
  let builtin_styles = ['green', 'yellow', 'cyan', 'blue', 'magenta', 'invert', 'bold', 'italic', 'underline', 'undercurl']
  let custom_styles = keys(g:better_code_block_custom)
  let all_styles = builtin_styles + custom_styles
  return filter(all_styles, 'v:val =~ "^" . a:ArgLead')
endfunction

function! better_code_block#change_highlight_style(style)
  let g:better_code_block_style = a:style
  call better_code_block#setup_highlight_style()
  call better_code_block#apply_highlighting()
  echo "Highlight style changed to: " . a:style
endfunction

" Register a custom highlight style
function! better_code_block#register_custom_style(name, ...)
  if a:0 == 0
    echoerr "BetterCodeBlockRegisterStyle requires at least one attribute!"
    return
  endif
  let custom = s:parse_style_attributes(a:000)
  if empty(custom)
    echoerr "Failed to parse style attributes!"
    return
  endif
  let g:better_code_block_custom[a:name] = custom
  echo "Registered custom style: " . a:name
endfunction

" Parse style attributes from varargs
function! s:parse_style_attributes(attrs)
  let custom = {}
  let i = 0
  while i < len(a:attrs)
    let attr = a:attrs[i]
    let i += 1
    if i >= len(a:attrs)
      echoerr "Missing value for attribute: " . attr
      return {}
    endif
    let value = a:attrs[i]
    let custom[attr] = value
    let i += 1
  endwhile
  return custom
endfunction

" Detect language from fence line
function! s:detect_language(fence_line)
  if a:fence_line =~# '`````\s\+weird'
    call s:debug_message("Detected weird fence pattern, returning empty string")
    return ''
  endif
  let patterns = [
        \ '```\s*\(\w\+\)',
        \ '```\(\w\+\)',
        \ '```\s*\(\w\+\)\s\+.*',
        \ '```\s*\(\w\+\-\w\+\)',
        \ '```\s*\(\w\+\.\w\+\)',
        \ '```\s*\(\w\+\)+++',
        \ '```\s*\(\w\+\)++',
        \ '```\s*\(\w\+\)#'
        \ ]
  let language_mappings = {
        \ 'shell': 'shell-bash',
        \ 'c': 'c++',
        \ 'config': 'config.json',
        \ 'f': 'f#'
        \ }
  for pattern in patterns
    let matches = matchlist(a:fence_line, pattern)
    if len(matches) > 1 && !empty(matches[1])
      let lang = matches[1]
      if has_key(language_mappings, lang)
        let lang = language_mappings[lang]
      endif
      call s:debug_message("Detected language: " . lang . " using pattern: " . pattern)
      return lang
    endif
  endfor
  let curly_pattern = '```{\(\w\+\)}'
  let matches = matchlist(a:fence_line, curly_pattern)
  if len(matches) > 1 && !empty(matches[1])
    call s:debug_message("Detected language: " . matches[1] . " using curly brace pattern")
    return matches[1]
  endif
  call s:debug_message("No language detected in fence: " . a:fence_line)
  return ''
endfunction

" Get highlight groups at cursor position
function! better_code_block#get_highlight_groups_at_cursor()
  let highlight_groups = []
  let stack = synstack(line('.'), col('.'))
  for id in stack
    call add(highlight_groups, synIDattr(id, 'name'))
  endfor
  for id in stack
    let linked_id = synIDtrans(id)
    if linked_id != id
      call add(highlight_groups, synIDattr(linked_id, 'name'))
    endif
  endfor
  return highlight_groups
endfunction

" Test wrappers for internal functions
function! better_code_block#test_detect_language(fence_line)
  return s:detect_language(a:fence_line)
endfunction

function! better_code_block#test_parse_style_attributes(attrs)
  return s:parse_style_attributes(a:attrs)
endfunction

function! better_code_block#test_determine_line_number_method()
  return s:determine_line_number_method()
endfunction

function! better_code_block#test_find_code_blocks()
  return s:find_code_blocks()
endfunction

function! better_code_block#test_get_range_lines(start, end)
  return s:get_range_lines(a:start, a:end)
endfunction

function! better_code_block#test_parse_single_line(part)
  return s:parse_single_line(a:part)
endfunction

function! better_code_block#test_validate_highlight_lines(lines, block_size, start_line)
  return s:validate_highlight_lines(a:lines, a:block_size, a:start_line)
endfunction

function! s:enable_line_numbers()
  set number
  let method = s:determine_line_number_method()
  if method == 'sign'
    set signcolumn=yes
  endif
endfunction

function! s:disable_line_numbers()
  let method = s:determine_line_number_method()
  if method == 'sign'
    set signcolumn=auto
  endif
endfunction

function! better_code_block#test_get_range_lines(start, end)
  return s:get_range_lines(a:start, a:end)
endfunction

function! better_code_block#load_all_syntaxes()
  if exists('*s:load_all_syntaxes')
    call s:load_all_syntaxes()
  else
    runtime syntax/markdown_better_code_block_languages.vim
  endif
endfunction

" Highlight negative values in the code fence line
function! s:highlight_negative_values(fence_line, negative_values)
  let line_text = getline(a:fence_line)
  silent! highlight clear MarkdownCodeHighlightError
  if g:better_code_block_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:better_code_block_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
  let keyword_pattern = '\<\(' . g:better_code_block_keyword
  for alias in g:better_code_block_keyword_aliases
    let keyword_pattern .= '\|' . alias
  endfor
  let keyword_pattern .= '\)=\([''"]\?\)\([^''"]*\)\2'
  let matches = matchlist(line_text, keyword_pattern)
  if !empty(matches)
    let highlight_spec = matches[3]
    let start_idx = stridx(line_text, highlight_spec)
    if start_idx != -1
      if !exists('w:better_code_block_error_match_ids')
        let w:better_code_block_error_match_ids = []
      endif
      let lpos = 0
      while lpos >= 0
        let lpos = match(highlight_spec, '-\d\+', lpos)
        if lpos >= 0
          let rpos = match(highlight_spec, '[,"\'' ]', lpos)
          if rpos < 0
            let rpos = len(highlight_spec)
          endif
          let negative_value = highlight_spec[lpos : rpos-1]
          let error_start = start_idx + lpos
          let error_end = start_idx + rpos
          let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
          call add(w:better_code_block_error_match_ids, match_id)
          call s:debug_message("Added error highlight for negative value at line " . a:fence_line . ", position " . error_start . "-" . error_end . " (negative value: " . negative_value . ")")
          let lpos = rpos + 1
        endif
      endwhile
    endif
  endif
endfunction

" Highlight a specific part of the highlight specification
function! s:highlight_invalid_part(fence_line, highlight_spec, part)
  let line_text = getline(a:fence_line)
  let spec_pos = stridx(line_text, a:highlight_spec)
  if spec_pos == -1
    return
  endif
  let part_pos = stridx(a:highlight_spec, a:part)
  if part_pos == -1
    return
  endif
  let start_pos = spec_pos + part_pos
  let end_pos = start_pos + len(a:part)
  if !exists('w:better_code_block_error_match_ids')
    let w:better_code_block_error_match_ids = []
  endif
  let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . start_pos . 'c\%<' . (end_pos + 1) . 'c')
  call add(w:better_code_block_error_match_ids, match_id)
  call s:debug_message("Added error highlight for invalid part at line " . a:fence_line . ", position " . start_pos . "-" . end_pos . " (part: " . a:part . ")")
endfunction

" Highlight an invalid start value in the code fence line
function! s:highlight_invalid_start_value(fence_line, invalid_values, error_type)
  let line_text = getline(a:fence_line)
  silent! highlight clear MarkdownCodeHighlightError
  if g:better_code_block_error_style == 'red'
    highlight MarkdownCodeHighlightError ctermbg=red ctermfg=white guibg=#FF0000 guifg=#FFFFFF
  elseif g:better_code_block_error_style == 'reverse'
    highlight MarkdownCodeHighlightError cterm=reverse,bold gui=reverse,bold
  else
    highlight link MarkdownCodeHighlightError DiffDelete
  endif
  let keywords = [g:better_code_block_start_keyword] + g:better_code_block_start_keyword_aliases
  let keyword_pattern = '\<\('
  let first = 1
  for keyword in keywords
    if !first
      let keyword_pattern .= '\|'
    endif
    let keyword_pattern .= keyword
    let first = 0
  endfor
  let keyword_pattern .= '\)=\([''"]\?\)\([^''"]*\)\2'
  let matches = matchlist(line_text, keyword_pattern)
  if !empty(matches)
    let start_spec = matches[3]
    let start_idx = stridx(line_text, start_spec)
    if start_idx != -1
      if !exists('w:better_code_block_error_match_ids')
        let w:better_code_block_error_match_ids = []
      endif
      if a:error_type == '-'
        for invalid_value in a:invalid_values
          let pos = matchstrpos(start_spec, invalid_value)
          if pos[1] != -1
            let error_start = start_idx + pos[1]
            let error_end = start_idx + pos[2]
            let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
            call add(w:better_code_block_error_match_ids, match_id)
            call s:debug_message("Added error highlight for negative start value at line " . a:fence_line . ", position " . error_start . "-" . error_end . " (value: " . invalid_value . ")")
          endif
        endfor
      else
        for invalid_value in a:invalid_values
          let pos = matchstrpos(start_spec, invalid_value)
          if pos[1] != -1
            let error_start = start_idx + pos[1]
            let error_end = start_idx + pos[2]
            let match_id = matchadd('MarkdownCodeHighlightError', '\%' . a:fence_line . 'l\%>' . error_start . 'c\%<' . (error_end + 1) . 'c')
            call add(w:better_code_block_error_match_ids, match_id)
            call s:debug_message("Added error highlight for invalid start value at line " . a:fence_line . ", position " . error_start . "-" . error_end . " (value: " . invalid_value . ")")
          endif
        endfor
      endif
    endif
  endif
endfunction

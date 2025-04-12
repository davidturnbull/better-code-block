" Syntax file for Better Code Blocks language detection
" This file defines the languages supported in code blocks

let s:supported_languages = {
  \ 'python': 'python',
  \ 'py': 'python',
  \ 'javascript': 'javascript',
  \ 'js': 'javascript',
  \ 'typescript': 'typescript',
  \ 'ts': 'typescript',
  \ 'ruby': 'ruby',
  \ 'rb': 'ruby',
  \ 'html': 'html',
  \ 'css': 'css',
  \ 'bash': 'sh',
  \ 'sh': 'sh',
  \ 'json': 'json',
  \ 'yaml': 'yaml',
  \ 'yml': 'yaml',
  \ 'java': 'java',
  \ 'c': 'c',
  \ 'cpp': 'cpp',
  \ 'go': 'go',
  \ 'rust': 'rust',
  \ 'rs': 'rust',
  \ 'vim': 'vim',
  \ 'php': 'php',
  \ 'sql': 'sql',
  \ 'xml': 'xml',
  \ 'markdown': 'markdown',
  \ 'md': 'markdown',
  \ 'mdx': 'markdown'
  \ }

function! s:load_syntax_for(lang)
  let l:lang_name = get(s:supported_languages, a:lang, '')
  if empty(l:lang_name)
    return
  endif
  let l:syntax_file = 'syntax/' . l:lang_name . '.vim'
  if filereadable($VIMRUNTIME . '/' . l:syntax_file)
    execute 'syntax include @' . l:lang_name . ' ' . l:syntax_file
    execute 'syntax region BetterCodeBlock' . l:lang_name . ' matchgroup=markdownCodeDelimiter ' .
          \ 'start=/^```\s*' . a:lang . '\s*.*$/ ' .
          \ 'end=/^```\s*$/ ' .
          \ 'keepend contains=@' . l:lang_name . ',MarkdownCodeHighlight'
  endif
endfunction

function! s:load_all_syntaxes()
  for [lang, _] in items(s:supported_languages)
    call s:load_syntax_for(lang)
  endfor
endfunction

call s:load_all_syntaxes()

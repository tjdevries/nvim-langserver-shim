
let s:diagnostic_severity = {
      \ 'Error': 1,
      \ 'Warning': 2,
      \ 'Informatin': 3,
      \ 'Hint': 4,
      \ }


" Basic Json Structures
"
""
" Get a position dictinoary like the position structure
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#position
function! langserver#util#get_position() abort
  return {'line': getline('.'), 'character': col('.')}
endfunction

""
" A range in a text document expressed as (zero-based) start and end positions.
" A range is comparable to a selection in an editor. Therefore the end position is exclusive.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#range
function! langserver#util#get_range(start, end) abort
  " TODO: Make sure that these are the correct relativeness,
  return {'start': a:start, 'end': a:end}
endfunction

""
" Represents a location inside a resource, such as a line inside a text file.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#location
function! langserver#util#get_location(start, end) abort
  return {
        \ 'uri': expand('%'),
        \ 'range': langserver#util#get_range(a:start, a:end)
        \ }
endfunction

""
" Represents a diagnostic, such as a compiler error or warning. Diagnostic objects are only valid in the scope of a resource.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#diagnostic
"
" @param start (int)
" @param end (int)
" @param message (str)
" @param options (dict): Contiainings items like:
"   @key severity (string): Matching key to s:diagnostic_severity
"   @key code TODO
"   @key source TODO
function! langserver#util#get_diagnostic(start, end, message, options) abort
  let return_dict = {
        \ 'range': langserver#util#get_range(a:start, a:end),
        \ 'messsage': a:message
        \ }

  if has_key(options, 'severity')
    let return_dict['severity'] = options['severity']
  endif

  if has_key(options, 'code')
    let return_dict['code'] = options['code']
  endif

  if has_key(options, 'source')
    let return_dict['source'] = options['source']
  endif

  return return_dict
endfunction



""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#goto-definition-request
"
" @param id (int | string): The ID of the request
" @param position (Optional[dict]):  {'line': int, 'character': int}
function! langserver#request#goToDefinition(id, ...) abort
  if a:0 > 0
    let l:position = a:1
  else
    let l:position = langserver#util#get_position()
  endif

  return langserver#message#content(
        \ a:id,
        \ 'textDocument/definition',
        \ {
          \ 'textDocument': "TODO",
          \ 'position': l:position,
        \ },
        \ )
endfunction

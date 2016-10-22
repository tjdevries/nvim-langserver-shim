

""
" Get a position dictinoary like the position structure
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#position
function! langserver#util#get_position() abort
  return {'line': getline('.'), 'character': col('.')}
endfunction

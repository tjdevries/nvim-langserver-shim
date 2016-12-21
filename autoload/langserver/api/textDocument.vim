""
function! langserver#api#textDocument#definition(request) abort
  return langserver#goto#goto_defintion(
        \ langserver#util#get_lsp_id(),
        \ a:request.result.uri,
        \ a:request.result.range,
        \ {},
        \ )
endfunction

function! langserver#api#textDocument#completion(request) abort

endfunction

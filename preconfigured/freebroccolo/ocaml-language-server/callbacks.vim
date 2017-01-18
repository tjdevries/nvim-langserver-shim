function! s:give_word_at_position(id, data, event) abort
  call langserver#log#server_request(a:id, a:data, a:event)
  "  'params': 
  "      {'uri': 'file:///home/tj/Downloads/example-ocaml-merlin/src/main.ml',
  "      'position': {'character': 9, 'line': 6}
  "      }
  if !has_key(a:data.request.params, 'uri') || !has_key(a:data.request.params, 'position')
    call langserver#log#log('error', 'Unable to handle callback for: ' . string(a:data), v:true)
    return
  endif

  if v:false
    let l:loc_bufnr = bufnr(langserver#util#get_filename(langserver#util#get_lsp_id(), a:data.request.params.uri))
    let l:loc_line = langserver#util#get_line(l:loc_bufnr, a:data.request.params.uri, a:data.request.params.position.line - 1)
  endif

  call langserver#client#send(a:id, {
        \ 'req_id': a:data.request.id,
        \ 'method': a:data.request.method,
        \ 'request': a:data.request,
        \ 'result': expand('<cword>'),
        \ 'response': {
          \ 'result': expand('<cword>'),
        \ },
        \ })
  return v:true
endfunction


function! Preconfigured_freebroccolo_ocaml_language_server() abort
  return {
      \ 'reason.client.giveWordAtPosition': function('s:give_word_at_position'),
      \ }
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Command handler
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! langserver#extension#command#callback(id, data, event) abort
  call langserver#log#server_request(a:id, a:data, a:event)

  if type(a:data) != type({})
    return
  endif

  let l:method = a:data.request.method

  if l:method ==? 'fs/readFile'
    let l:response = langserver#extension#fs#readFille(a:data.request.params)
  else
    call langserver#log#log('warning', 'No matching callback found for: ' . l:method)
    return v:false
  endif

  call langserver#client#send(a:id, {
        \ 'req_id': a:data.request.id,
        \ 'method': 'fs/readFile',
        \ 'params': {
          \ 'result': l:response,
          \ },
        \ })
  return v:true
endfunction

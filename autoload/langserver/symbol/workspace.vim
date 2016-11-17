let s:method = 'workspace/symbol'

function! langserver#symbol#workspace#callback(id, data, event) abort
  let l:parsed_data = langserver#callbacks#data(a:id, a:data, a:event)
  if type(l:parsed_data) == type('') && l:parsed_data ==? ''
    return
  endif

  call langserver#log#log('info', a:data, v:true)
endfunction

function!langserver#symbol#workspace#request(...) abort
   if a:0 > 0
      let l:query = a:1
   else
      let l:query = expand('<cword>')
   endif

   return langserver#client#send(langserver#util#get_lsp_id(), {
            \ 'method': s:method,
            \ 'params': {'query': l:query}
            \ })
endfunction

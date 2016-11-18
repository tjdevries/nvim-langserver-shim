let s:method = 'workspace/symbol'

function! langserver#symbol#workspace#callback(id, data, event) abort
  let l:parsed_data = langserver#callbacks#data(a:id, a:data, a:event)
  if type(l:parsed_data) == type('') && l:parsed_data ==? ''
    return
  endif

  let l:transformed = langserver#symbol#util#transform_reply(l:parsed_data) 
  call langserver#symbol#workspace#display(l:transformed)
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

function! langserver#symbol#workspace#display(loc_list) abort
  call langserver#log#log('debug', string(a:loc_list))

  call setqflist(a:loc_list)
endfunction

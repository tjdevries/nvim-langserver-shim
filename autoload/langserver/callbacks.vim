function! langserver#callbacks#on_stdout(id, data, event) abort
  echom 'LSP STDOUT(' . a:id . '): ' . string(a:data)
endfunction

function! langserver#callbacks#on_stderr(id, data, event) abort
  call langserver#log#response(a:id, a:data, a:event)
endfunction

function! langserver#callbacks#on_exit(id, status, event) abort
  echom 'lsp('.a:id.'):exit:'.a:status
endfunction

function! langserver#callbacks#on_notification(id, data, event) abort

  if has_key(a:data, 'response')
    call langserver#log#response(a:id, a:data, a:event)

    let l:last_topic = a:data['request']['method']

    if l:last_topic ==? 'textDocument/references'
      call langserver#references#callback(a:id, a:data, a:event)
    elseif l:last_topic ==? 'textDocument/definition'
      call langserver#goto#callback(a:id, a:data, a:event)
    elseif l:last_topic ==? 'textDocument/hover'
      call langserver#hover#callback(a:id, a:data, a:event)
    elseif l:last_topic ==? 'textDocument/didOpen'
      call langserver#documents#callback_did_open(a:id, a:data, a:event)
    elseif l:last_topic ==? 'workspace/symbol'
      call langserver#symbol#workspace#callback(a:id, a:data, a:event)
    else
      call langserver#log#log('warning', 'LAST REQUEST: ' . l:last_topic, v:true)
    endif
  endif

  if langserver#client#is_error(a:data.response)
    echom 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method
  else
    if langserver#util#debug()
      " echom 'lsp('.a:id.'):notification:notification success receieved for '.a:data.request.method
    endif

    if a:data.request.method ==? 'textDocument/references'
      echom 'LSP NOTIFI References Method matched: ' . string(a:data.request)
      " call langserver#references#callback(a:data.request)
    endif
  endif
endfunction

function! langserver#callbacks#data(id, data, event) abort
  call langserver#log#callback(a:id, a:data, a:event)

  if type(a:data) != type({})
    return ''
  endif

  if has_key(a:data, 'response')
    let l:parsed_data = a:data['response']['result']
  else
    return ''
  endif

  let g:last_response = l:parsed_data
  return l:parsed_data
endfunction

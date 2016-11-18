function! langserver#callbacks#on_stdout(id, data, event) abort
  echom 'LSP STDOUT(' . a:id . '): ' . string(a:data)
endfunction

function! langserver#callbacks#on_stderr(id, data, event) abort
  echom 'stderr ...'
  call langserver#log#response(a:id, a:data, a:event)

  echom string(a:data)
  echom '...stderr'
endfunction

function! langserver#callbacks#on_exit(id, status, event) abort
  echom 'lsp('.a:id.'):exit:'.a:status
endfunction

function! langserver#callbacks#on_notification(id, data, event) abort
  if a:event ==? 'on_request'
    call langserver#extension#command#callback(a:id, a:data, a:event)
  elseif a:event ==? 'on_notification'
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
        " if langserver#extension#command#callback(a:id, a:data, a:event)
        "   call langserver#log#log('debug', 'Handled: ' . l:last_topic)
        " else
          call langserver#log#log('warning', 'LAST REQUEST: ' . l:last_topic, v:true)
        " endif
      endif
    elseif has_key(a:data, 'request')
      echom 'notification...'
      echom string(a:data)
      echom '...notification'
    endif

    if langserver#client#is_error(a:data.response)
      call langserver#log#log('debug',
            \ 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method,
            \ v:true,
            \ )
    else
      call langserver#log#log('debug',
            \ 'lsp('.a:id.'):notification:notification success receieved for '.a:data.request.method,
            \ langserver#util#debug(),
            \ )
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

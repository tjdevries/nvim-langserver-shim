function! s:check_extra_callbacks(last_topic) abort
  echom 'Checking custom callbacks'
  let l:custom_callbacks = langserver#default#extension_callbacks()
  echom 'Custom callbacks are: ' . string(l:custom_callbacks)
  if has_key(l:custom_callbacks, a:last_topic)
    call langserver#log#log('info', 'Calling custom callback for: ' . a:last_topic, v:true)
    return l:custom_callbacks[a:last_topic]
  else
    call langserver#log#log('warning', 'No callback registered for: ' . a:last_topic, v:true)
    return v:false
  endif
endfunction

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
  if a:event ==? 'on_request'
    let l:last_topic = a:data['request']['method']

    let l:ExtraCallbacks = s:check_extra_callbacks(l:last_topic)

    if type(l:ExtraCallbacks) == type(function('tr'))
      let l:result = call(l:ExtraCallbacks, [a:id, a:data, a:event])
    else
      call langserver#extension#command#callback(a:id, a:data, a:event)
    endif
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
      elseif l:last_topic ==? 'initialize'
        call langserver#initialize#callback(a:id, a:data, a:event)
      elseif l:last_topic ==? 'workspace/symbol'
        call langserver#symbol#workspace#callback(a:id, a:data, a:event)
      else
        " Check if any extra callbacks exist.
        let l:ExtraCallbacks = s:check_extra_callbacks(l:last_topic)

        if type(l:ExtraCallbacks) == type(function('tr'))
          let l:result = call(l:ExtraCallbacks, [a:id, a:data, a:event])
        endif
      endif
    elseif has_key(a:data, 'request')
      echom 'notification...'
      echom string(a:data)
      echom '...notification'
    endif

    if langserver#client#is_error(a:data.response)
      call langserver#log#log('debug',
            \ 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method .
            \ ': ' . string(a:data),
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
  let g:last_response = a:data

  if type(a:data) != type({})
    return {}
  endif

  if has_key(a:data, 'response')
    let l:parsed_data = a:data['response']['result']
  else
    return {}
  endif

  return l:parsed_data
endfunction

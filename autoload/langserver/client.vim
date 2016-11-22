let s:lsp_clients = {} " { id, opts, req_seq, on_notifications: { request, on_notification }, stdout: { max_buffer_size, buffer, next_token, current_content_length, current_content_type } }
let s:lsp_token_type_contentlength = 'content-length'
let s:lsp_token_type_contenttype = 'content-type'
let s:lsp_token_type_message = 'message'
let s:lsp_default_max_buffer = -1

let s:lsp_text_document_sync_kind_none = 0
let s:lsp_text_document_sync_kind_full = 1
let s:lsp_text_document_sync_kind_incremental = 2

function! s:_on_lsp_stdout(id, data, event) abort
    if has_key(s:lsp_clients, a:id)
        let l:client = s:lsp_clients[a:id]

        let l:client.stdout.buffer .= join(a:data, "\n")

        if l:client.stdout.max_buffer_size != -1 && len(l:client.stdout.buffer) > l:client.stdout.max_buffer_size
            echom 'lsp: reached max buffer size'
            call langserver#job#stop(a:id)
        endif

        while 1
            if l:client.stdout.next_token == s:lsp_token_type_contentlength
                let l:new_line_index = stridx(l:client.stdout.buffer, "\r\n")
                if l:new_line_index >= 0
                    let l:content_length_str = l:client.stdout.buffer[:l:new_line_index - 1]
                    let l:client.stdout.buffer = l:client.stdout.buffer[l:new_line_index + 2:]
                    let l:client.stdout.current_content_length = str2nr(split(l:content_length_str, ':')[1], 10)
                    let l:client.stdout.next_token = s:lsp_token_type_contenttype
                    continue
                else
                    " wait for next buffer to arrive
                    break
                endif
            elseif l:client.stdout.next_token == s:lsp_token_type_contenttype
                let l:new_line_index = stridx(l:client.stdout.buffer, "\r\n")
                if l:new_line_index >= 0
                    let l:content_type_str = l:client.stdout.buffer[:l:new_line_index - 1]
                    let l:client.stdout.buffer = l:client.stdout.buffer[l:new_line_index + 4:]
                    let l:client.stdout.current_content_type = l:content_type_str
                    let l:client.stdout.next_token = s:lsp_token_type_message
                    continue
                else
                    " wait for next buffer to arrive
                    break
                endif
            else " we are reading a message
                if len(l:client.stdout.buffer) >= l:client.stdout.current_content_length
                    " we have complete message
                    let l:response_str = l:client.stdout.buffer[:l:client.stdout.current_content_length - 1]
                    let l:client.stdout.buffer = l:client.stdout.buffer[l:client.stdout.current_content_length :]
                    let l:client.stdout.next_token = s:lsp_token_type_contentlength
                    let l:response_msg = json_decode(l:response_str)
                    if has_key(l:response_msg, 'id') && has_key(l:client.on_notifications, l:response_msg.id)
                        let l:on_notification_data = { 'request': l:client.on_notifications[l:response_msg.id].request, 'response': l:response_msg }
                        if has_key(l:client.opts, 'on_notification')
                            call l:client.opts.on_notification(a:id, l:on_notification_data, 'on_notification')
                        endif
                        if has_key(l:client.on_notifications, 'on_notification')
                            call l:client.on_notifications[l:response_msg.id](a:id, l:on_notification_data, 'on_notification')
                        endif
                        call remove(l:client.on_notifications, l:response_msg.id)
                    else
                        echom string(l:client)
                        let l:on_notification_data = {
                                    \ 'request': l:response_msg,
                                    \ }
                        call l:client.opts.on_notification(a:id, l:on_notification_data, 'on_request')
                    endif
                    continue
                else
                    " wait for next buffer to arrive since we have incomplete message
                    break
                endif
            endif
        endwhile
    endif
endfunction

function! s:_on_lsp_stderr(id, data, event) abort
    if has_key(s:lsp_clients, a:id)
        let l:client = s:lsp_clients[a:id]
        if has_key(l:client.opts, 'on_stderr')
            call l:client.opts.on_stderr(a:id, a:data, a:event)
        endif
    endif
endfunction

function! s:_on_lsp_exit(id, status, event) abort
    if has_key(s:lsp_clients, a:id)
        let l:client = s:lsp_clients[a:id]
        if has_key(l:client.opts, 'on_exit')
            call l:client.opts.on_exit(a:id, a:status, a:event)
        endif
    endif
endfunction

function! s:lsp_start(opts) abort
    if !has_key(a:opts, 'cmd')
        return -1
    endif

    let l:lsp_client_id = langserver#job#start(a:opts.cmd, {
        \ 'on_stdout': function('s:_on_lsp_stdout'),
        \ 'on_stderr': function('s:_on_lsp_stderr'),
        \ 'on_exit': function('s:_on_lsp_exit'),
    \ })

    let l:max_buffer_size = s:lsp_default_max_buffer
    if has_key(a:opts, 'max_buffer_size')
        let l:max_buffer_size = a:opts.max_buffer_size
    endif

    let s:lsp_clients[l:lsp_client_id] = {
        \ 'id': l:lsp_client_id,
        \ 'opts': a:opts,
        \ 'req_seq': 0,
        \ 'on_notifications': {},
        \ 'stdout': {
            \ 'max_buffer_size': l:max_buffer_size,
            \ 'buffer': '',
            \ 'next_token': s:lsp_token_type_contentlength,
        \ },
    \ }

    return l:lsp_client_id
endfunction

function! s:lsp_stop(id) abort
    call langserver#job#stop(a:id)
endfunction

function! s:lsp_send_request(id, opts) abort " opts = { method, params?, on_notification }
    if has_key(s:lsp_clients, a:id)
        let l:client = s:lsp_clients[a:id]

        if has_key(a:opts, 'req_id')
            let l:req_seq = a:opts.req_id
        else
            let l:client.req_seq = l:client.req_seq + 1
            let l:req_seq = l:client.req_seq
        endif

        let l:msg = { 'jsonrpc': '2.0', 'id': l:req_seq, 'method': a:opts.method }
        if has_key(a:opts, 'params')
            let l:msg.params = a:opts.params
        endif

        if has_key(a:opts, 'result')
            let l:msg.result = a:opts.result
        endif

        let l:json = json_encode(l:msg)
        let l:req_data = 'Content-Length: ' . len(l:json) . "\r\n\r\n" . l:json

        let l:client.on_notifications[l:req_seq] = { 'request': l:msg }
        if has_key(a:opts, 'on_notification')
            let l:client.on_notifications[l:req_seq].on_notification = a:opts.on_notification
        endif

        if has_key(a:opts, 'on_stderr')
            let l:client.opts.on_stderr = a:opts.on_stderr
        endif

        call langserver#log#log('debug', printf('Sending request: %s, %s',
                    \ a:id,
                    \ string(l:msg)
                    \ ))
        call langserver#job#send(l:client.id, l:req_data)

        return l:req_seq
    else
        return -1
    endif
endfunction

function! s:lsp_get_last_request_id(id) abort
    return s:lsp_clients[a:id].req_seq
endfunction

function! s:lsp_is_error(notification) abort
    return has_key(a:notification, 'error')
endfunction

" public apis {{{

let g:langserver#client#text_document_sync_kind_none = s:lsp_text_document_sync_kind_none
let g:langserver#client#text_document_sync_kind_full = s:lsp_text_document_sync_kind_full
let g:langserver#client#text_document_sync_kind_incremental = s:lsp_text_document_sync_kind_incremental

function! langserver#client#start(opts) abort
    return s:lsp_start(a:opts)
endfunction

function! langserver#client#stop(client_id) abort
    return s:lsp_stop(a:client_id)
endfunction

function! langserver#client#send(client_id, opts) abort
    return s:lsp_send_request(a:client_id, a:opts)
endfunction

function! langserver#client#get_last_request_id(client_id) abort
    return s:lsp_get_last_request_id(a:client_id)
endfunction

function! langserver#client#is_error(notification) abort
    return s:lsp_is_error(a:notification)
endfunction

" }}}
" vim sw=4 ts=4 et

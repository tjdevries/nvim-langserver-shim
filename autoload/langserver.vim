let g:lsp_id_map = get(g:, 'lsp_id_map', {})

""
" Start the langauage server and return the ID
"
" @param options (dict): {cmd, on_stderr?, on_exit?, on_notification?}
function! langserver#start(options) abort
    if has_key(a:options, 'cmd')
        let l:cmd = a:options['cmd']
    else
        let l:cmd = langserver#default#cmd()
        if l:cmd == [-1]
            echom 'No valid langserver for ' . &filetype . '. Please modify `g:langserver_executables`'
            return
        endif
    endif

    let l:lsp_id = langserver#client#start({
                \ 'cmd': l:cmd,
                \ 'on_stdout': function('langserver#callbacks#on_stdout'),
                \ 'on_stderr': function('langserver#callbacks#on_stderr'),
                \ 'on_exit': function('langserver#callbacks#on_exit'),
                \ 'on_notification': function('langserver#callbacks#on_notification')
                \ })

    if has_key(a:options, 'root_path')
        let l:root_path = a:options['root_path']
    else
        let l:root_path = langserver#util#get_root_path(l:lsp_id)
    endif

    if l:lsp_id > 0
       echom 'lsp server running'
       call langserver#client#send(l:lsp_id, {
                \ 'method': 'initialize',
                \ 'params': {
                   \ 'capabilities': {},
                   \ 'rootPath': l:root_path,
                \ },
                \ })
    else
       echom 'failed to start lsp server'
    endif

    let g:lsp_id_map[&filetype] = l:lsp_id

    return l:lsp_id
endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didchangetextdocument-notification
function! langserver#didChangeTextDocument() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didclosetextdocument-notification
function! langserver#didCloseTextDocument() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didsavetextdocument-notification
function! langserver#didSaveTextDocument() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didchangewatchedfiles-notification
function! langserver#didChangeWatchedFiles() abort

endfunction

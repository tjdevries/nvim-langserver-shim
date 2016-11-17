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
            call langserver#log#log('error', 'No valid langserver for ' . &filetype . '. Please modify `g:langserver_executables`', v:true)
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
       call langserver#log#log('info', 'lsp server running')
       call langserver#client#send(l:lsp_id, {
                \ 'method': 'initialize',
                \ 'params': {
                   \ 'capabilities': {},
                   \ 'rootPath': l:root_path,
                \ },
                \ })
    else
       call langserver#log#log('error', 'failed to start lsp server', v:true)
    endif

    let g:lsp_id_map[&filetype] = l:lsp_id

    return l:lsp_id
endfunction

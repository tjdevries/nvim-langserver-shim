function! langserver#documents#callback_did_open(id, data, event) abort
   call langserver#log#callback(a:id, a:data, a:event)

   if type(a:data) != type({})
      return
   endif

   let g:last_response = a:data
   call langserver#log#log('info', string(a:data))
endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didopentextdocument-notification
function! langserver#documents#did_open() abort
    " Open the new file
    " execute(':edit ' . a:filename)

    " TODO: Just assume that the server is the filetype for now.
    let l:server_name = langserver#util#get_lsp_id()
    let l:filename_uri = langserver#util#get_uri(l:server_name, expand('%'))

    return langserver#client#send(langserver#util#get_lsp_id(), {
             \ 'method': 'textDocument/didOpen',
             \ 'params': langserver#util#get_text_document_identifier(l:server_name),
             \ })
endfunction


""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didchangetextdocument-notification
function! langserver#documents#did_change() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didclosetextdocument-notification
function! langserver#documents#did_close() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didsavetextdocument-notification
function! langserver#documents#did_save() abort

endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didchangewatchedfiles-notification
function! langserver#documents#did_change_watched_files() abort

endfunction

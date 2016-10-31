
""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didopentextdocument-notification
function! langserver#didOpenTextDocument(filename) abort
    " Open the new file
    execute(':edit ' . a:filename)

    " TODO: Just assume that the server is the filetype for now.
    let l:server_name = &filetype
    let l:filename_uri = langserver#util#get_uri(l:server_name, expand('%'))
    let l:content_dict = langserver#util#get_text_document_item(l:server_name, expand('%'))

    call langserver#message#send(l:server_name, 'textDocument/didOpen', l:content_dict)
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

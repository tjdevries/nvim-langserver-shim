function! s:on_did_open_request(id, data, event) abort
   let parsed = langserver#util#parse_message(a:data)
   let g:last_response = parsed

   echom string(parsed)
endfunction

""
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didopentextdocument-notification
function! langserver#documents#did_open() abort
    " Open the new file
    " execute(':edit ' . a:filename)

    " TODO: Just assume that the server is the filetype for now.
    let l:server_name = langserver#util#get_lsp_id()
    let l:filename_uri = langserver#util#get_uri(l:server_name, expand('%'))

    return lsp#lspClient#send(langserver#util#get_lsp_id(), {
             \ 'method': 'textDocument/didOpen',
             \ 'params': langserver#util#get_text_document_identifier(l:server_name),
             \ 'on_notification': function('s:on_did_open_request'),
             \ 'on_stderr': function('s:on_did_open_request'),
             \ })
endfunction


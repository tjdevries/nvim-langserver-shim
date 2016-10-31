

let g:langserver_configuration = {
      \ 'json_rpc_version': "2.0",
      \ }


" Open a text document, and alert the language server
command LSPOpen call langserver#didOpenTextDocument()



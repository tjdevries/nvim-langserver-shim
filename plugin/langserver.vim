

let g:langserver_configuration = {
      \ 'json_rpc_version': "2.0",
      \ }


" Start the language server
command! LSPStart call langserver#start({})

" Open a text document, and alert the language server
command! LSPOpen call langserver#didOpenTextDocument()

nnoremap <leader>gd :call langserver#goto#request(langserver#util#get_lsp_id())<CR>

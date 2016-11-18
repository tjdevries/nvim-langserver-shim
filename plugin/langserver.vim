

let g:langserver_configuration = {
      \ 'json_rpc_version': '2.0',
      \ }


" Start the language server
command! LSPStart call langserver#start({})

" Open a text document, and alert the language server
command! LSPOpen call langserver#didOpenTextDocument()

" Request a goto
command! LSPGoto call langserver#goto#request()

" Request a hover
command! LSPHover call langserver#hover#request()



nnoremap <leader>gd :call langserver#goto#request()<CR>
nnoremap <leader>gh :call langserver#hovoer#request()<CR>

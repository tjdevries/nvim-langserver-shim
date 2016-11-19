

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

let s:mapping_options = get(g:, 'langserver_mapping_options', {})
call langserver#mappings#default(s:mapping_options)
nmap <leader>gd <Plug>(langserver_goto_request)
nmap <leader>gh <Plug>(langserver_hover_request)

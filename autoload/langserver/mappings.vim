

function! langserver#mappings#default(opts) abort
  " Goto mappings
  nnoremap <Plug>(langserver_goto_request) :<c-u>call langserver#goto#request()<CR>

  " Hover mappings
  nnoremap <silent> <Plug>(langserver_hover_request) :call langserver#hover#request()<CR>

  " Reference mappings
  nnoremap <silent> <Plug>(langserver_textdocument_references_request) :call langserver#references#request()<CR>
endfunction


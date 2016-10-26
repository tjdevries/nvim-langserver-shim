let s:TextDocumentSyncKind = {
      \ 'name': {
        \ 'None': 0,
        \ 'Full': 1,
        \ 'Incremental': 2
        \ },
      \ 'number': {
        \ 0: 'None',
        \ 1: 'Full',
        \ 2: 'Incremental'
        \ },
      \ }

" In case this has been set somehow. Not sure if I want to do it like this,
" but it should guard against anything overwriting this
let g:langserver_capabilities = get(g, 'langserver_capabilities', {})

""
" Makes sure that the dictionary is prepared to record the capabilities of
" server {name}
"
" @param name (str): The name of the server
function! s:prepare_capabiilties(name) abort
  if !has_key(g:langserver_capabilities, a:name)
    let g:langserver_capabilities[a:name] = {}
  endif
endfunction

"------------------- Various setters ------------------------------------------

""
" @param name (str): The name of the server
" @param kind (int): The corresponding document sync kind
function! langserver#capabilities#set_test_document_sync_kind(name, kind) abort
  call s:prepare_capabiilties(a:name)

  " Set the value to a human readable value
  let g:langserver_capabilities[a:name]['textDocumentSync'] = s:TextDocumentSyncKind['number'][a:kind]
endfunction

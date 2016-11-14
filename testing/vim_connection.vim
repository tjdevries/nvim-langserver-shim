let s:langserver_executabe = 'langserver-go'
let s:langserver_name = 'go'

function! s:on_stderr(id, data, event)
   " TODO: some function that parses this easily.
   " let split_data = split(a:data[0], ':')
   " echom '{' . join(split_data[1:], ':') . '}'
   " return

   " if v:true || has_key(a:data, 'textDocument/definition')
   "    echom 'lsp has found definition'
   " else
   echom 'lsp('.a:id.'):stderr: Event:' . a:event . ' ==> ' . join(a:data, "\r\n")
   " endif
endfunction

function! s:on_exit(id, status, event)
   echom 'lsp('.a:id.'):exit:'.a:status
endfunction

function! s:on_notification(id, data, event)
   if lsp#lspClient#is_error(a:data.response)
      echom 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method
   else
      echom 'lsp('.a:id.'):notification:notification success receieved for '.a:data.request.method
   endif
endfunction

function! s:on_notification1(id, data, event)
   echom 'lsp('.a:id.'):notification1:'json_encode(a:data)
endfunction

" go get github.com/sourcegraph/go-langserver/langserver/cmd/langserver-go
let g:lsp_id = lsp#lspClient#start({
         \ 'cmd': [s:langserver_executabe, '-trace', '-logfile', expand('~/Desktop/langserver-go.log')],
         \ 'on_stderr': function('s:on_stderr'),
         \ 'on_exit': function('s:on_exit'),
         \ 'on_notification': function('s:on_notification')
         \ })

if g:lsp_id > 0
   echom 'lsp server running'
   call lsp#lspClient#send(g:lsp_id, {
            \ 'method': 'initialize',
            \ 'params': {
               \ 'capabilities': {},
               \ 'rootPath': 'file:///home/tj/go/src/github.com/sourcegraph/go-langserver',
            \ },
            \ 'on_notification': function('s:on_notification1')
            \ })
else
   echom 'failed to start lsp server'
endif

sleep 1

function! s:on_definition_request(id, data, event)
   if type(a:data) != type([]) || a:data[0] =~? '.*request.*'
      echom a:data
      return
   endif

   echom 'This is the orig data : ' . string(a:data)
   let split_data = json_decode(split(a:data[0], 'textDocument/definition: ')[1])
   echom 'This is the split data: ' . string(a:split_data)
   " echom 'This is the thing: ' . string(split_data)

   if has_key(split_data, 'textDocument') && has_key(split_data, 'range')
      echom 'URI:        ' . string(split_data['textDocument'])
      echom 'Range dict: ' . string(split_data['range'])
   endif
   " call langserver#goto#goto_defintion(g:lsp_id, split_data['textDocument'], 
endfunction

function! SendDefinitionRequest() abort
   call lsp#lspClient#send(g:lsp_id, {
            \ 'method': 'textDocument/definition',
            \ 'params': {
               \ 'textDocument': langserver#util#get_text_document_identifier(s:langserver_name),
               \ 'position': langserver#util#get_position(),
            \ },
            \ 'on_notification': function('s:on_definition_request'),
            \ 'on_stderr': function('s:on_definition_request'),
            \ })
endfunction

call lsp#lspClient#stop(g:lsp_id)

let s:langserver_executabe = 'langserver-go'
let s:langserver_name = 'go'

let s:debug = v:false

function! s:on_stderr(id, data, event)
   " TODO: some function that parses this easily.
   " let split_data = split(a:data[0], ':')
   " echom '{' . join(split_data[1:], ':') . '}'
   " return

   " if v:true || has_key(a:data, 'textDocument/definition')
   "    echom 'lsp has found definition'
   " else
   echom 'lsp('.a:id.'):stderr: Event:' . a:event . ' ==> ' . join(a:data, "\r\n")

   let parsed = langserver#util#parse_message(a:data)
   echom 'Resulting data is: ' . string(parsed)
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
   let parsed = langserver#util#parse_message(a:data)
   let g:last_response = parsed

   if parsed['type'] ==# 'result'
      let data = parsed['data']['textDocument/definition'][0]
   else
      return
   endif

   if s:debug
      echom string(a:data)
      echom 'Definition data is: ' . string(parsed)
   else
      " {'data':
      "     {'textDocument/definition':
      "         [
      "             {'uri': 'file:///home/tj/go/src/github.com/sourcegraph/go-langserver/langserver/util.go',
      "              'range': {
      "                 'end': {'character': 29, 'line': 15},
         "              'start': {'character': 23, 'line': 15}}
         "          }
      "         ]
   "         },
   "         'type': 'result'}
      call langserver#goto#goto_defintion(g:lsp_id, data['uri'], data['range'], {})
   endif
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

" call lsp#lspClient#stop(g:lsp_id)

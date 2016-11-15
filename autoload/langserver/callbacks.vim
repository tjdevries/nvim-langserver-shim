function! langserver#callbacks#on_stderr(id, data, event)
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

function! langserver#callbacks#on_exit(id, status, event)
   echom 'lsp('.a:id.'):exit:'.a:status
endfunction

function! langserver#callbacks#on_notification(id, data, event)
   if lsp#lspClient#is_error(a:data.response)
      echom 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method
   else
      echom 'lsp('.a:id.'):notification:notification success receieved for '.a:data.request.method
   endif
endfunction

function! langserver#callbacks#on_notification1(id, data, event)
   echom 'lsp('.a:id.'):notification1:'json_encode(a:data)
endfunction


function! langserver#callbacks#on_stdout(id, data, event) abort
   echom 'LSP STDOUT(' . a:id . '): ' . string(a:data)
endfunction

function! langserver#callbacks#on_stderr(id, data, event) abort
   " TODO: some function that parses this easily.
   " let split_data = split(a:data[0], ':')
   " echom '{' . join(split_data[1:], ':') . '}'
   " return

   " if v:true || has_key(a:data, 'textDocument/definition')
   "    echom 'lsp has found definition'
   " else
   echom 'lsp('.a:id.'):stderr: Event:' . a:event . ' ==> ' . join(a:data, "\r\n")

   " let parsed = langserver#util#parse_message(a:data)
   " echom 'Resulting data is: ' . string(parsed)
   " echom 'STDERR: Request ' . string(a:data.request)
endfunction

function! langserver#callbacks#on_exit(id, status, event) abort
   echom 'lsp('.a:id.'):exit:'.a:status
endfunction

function! langserver#callbacks#on_notification(id, data, event) abort

   if has_key(a:data, 'response')
      if langserver#util#debug()
         let g:last_response = a:data
         echom 'LSP RSP: ' . string(a:data)
      endif

      let l:last_topic = a:data['request']['method']

      if l:last_topic ==? 'textDocument/references'
         call langserver#references#callback(a:id, a:data, a:event)
      elseif l:last_topic ==? 'textDocument/definition'
         call langserver#goto#callback(a:id, a:data, a:event)
      elseif l:last_topic ==? 'textDocument/hover'
         call langserver#hover#callback(a:id, a:data, a:event)
      else
         call langserver#log#log('warning', 'LAST REQUEST: ' . l:last_topic, v:true)
      endif
   endif

   if langserver#client#is_error(a:data.response)
      echom 'lsp('.a:id.'):notification:notification error receieved for '.a:data.request.method
   else
      if langserver#util#debug()
         " echom 'lsp('.a:id.'):notification:notification success receieved for '.a:data.request.method
      endif

      if a:data.request.method ==? 'textDocument/references'
         echom 'LSP NOTIFI References Method matched: ' . string(a:data.request)
         " call langserver#references#callback(a:data.request)
      endif
   endif
endfunction

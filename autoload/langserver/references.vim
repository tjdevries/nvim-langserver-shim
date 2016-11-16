let s:method = 'textDocument/references'

function! langserver#references#transform_reply(message) abort
   " {'bufnr': bufnr('%'), 'lnum': 2, 'col': 8, 'text': 'Testing...', 'type': 'W'},

   let l:location_list = []
   for location in a:message['data'][s:method]
      let loc_bufnr = bufnr(langserver#util#get_filename(langserver#util#get_lsp_id(), location['uri']))
      let loc_line = location['range']['start']['line'] + 1
      let loc_text = bufnr('%') == loc_bufnr ? getline(loc_line) : ''

      let location_dict = {
               \ 'bufnr': loc_bufnr,
               \ 'lnum': loc_line,
               \ 'col': location['range']['start']['character'] + 1,
               \ 'text': loc_text,
               \ 'type': 'x'
               \ }
      call add(l:location_list, location_dict)
   endfor

   return l:location_list
endfunction

function! langserver#references#callback(id, data, event) abort
   echom 'THIS IS IN THE REF CALLBACK'
   if has_key(a:data, 'response')
      echom string(a:data.response)
   endif
   return

   let parsed = langserver#util#parse_message(a:data)
   let g:last_response = parsed

   if parsed['type'] ==# 'result'
      let loc_list = langserver#references#transform_reply(parsed)
   else
      return
   endif

   call langserver#references#display(loc_list)
endfunction

function! langserver#references#request() abort
   let l:params = langserver#util#get_text_document_position_params()
   call extend(l:params, {'context': {'includeDeclaration': v:true}})

   let g:_last_topic_sent = s:method
   return lsp#lspClient#send(langserver#util#get_lsp_id(), {
            \ 'method': s:method,
            \ 'params': l:params,
            \ })
endfunction

function! langserver#references#display(loc_list) abort
   if langserver#util#debug()
      echo 'Displaying references'
      echo string(a:loc_list)
   endif

   " TODO: Highlight the references, and turn them off somehow
   call setloclist(0,
            \ a:loc_list,
            \ 'r',
            \ '[Location References]',
            \ )
endfunction

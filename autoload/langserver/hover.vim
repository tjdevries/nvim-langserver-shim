function! s:on_hover_request(id, data, event) abort
   let parsed = langserver#util#parse_message(a:data)
   let g:last_response = parsed


" {'data': {'textDocument/hover': {'range': {'end': {'character': 20, 'line': 44}, 'start': {'character': 9, 'line': 44}}, 'contents': [{'language': 'go', 'value': 'type LangHandler struct'}, {'language': 'markdown', 'value': 'LangHandler is a Go language server LSP/JSON-RPC handler.'}]}}, 'type': 'result'}
   if parsed['type'] ==# 'result'
      " TODO: Correctly parse data
      let range = parsed['data']['textDocument/hover']['range']
      let data = parsed['data']['textDocument/hover']['contents']
   else
      return
   endif

   call langserver#hover#display(range, data)
endfunction

function! langserver#hover#request() abort
   return lsp#lspClient#send(langserver#util#get_lsp_id(), {
            \ 'method': 'textDocument/hover',
            \ 'params': langserver#util#get_text_document_position_params(),
            \ 'on_notification': function('s:on_hover_request'),
            \ 'on_stderr': function('s:on_hover_request'),
            \ })
endfunction

function! langserver#hover#display(range, data) abort
   let s:my_last_highlight = matchaddpos("WarningMsg", langserver#highlight#matchaddpos_range(a:range))
   redraw

   let hover_string = ''
   for explanation in a:data
      let hover_string .= printf("%s: %s\n",
               \ explanation['language'],
               \ explanation['value'],
               \ )
   endfor

   echo hover_string

   return timer_start(5000, function('s:delete_highlight'))
endfunction

function! s:delete_highlight() abort
   silent! call matchdelete(s:my_last_highlight)
endfunction

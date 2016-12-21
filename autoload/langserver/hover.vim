function! langserver#hover#callback(id, data, event) abort
  let l:parsed_data = langserver#callbacks#data(a:id, a:data, a:event)
  if l:parsed_data == {}
    return
  endif

  " {'data': {'textDocument/hover': {'range': {'end': {'character': 20, 'line': 44}, 'start': {'character': 9, 'line': 44}}, 'contents': [{'language': 'go', 'value': 'type LangHandler struct'}, {'language': 'markdown', 'value': 'LangHandler is a Go language server LSP/JSON-RPC handler.'}]}}, 'type': 'result'}
  if has_key(l:parsed_data, 'range')
    let l:range = l:parsed_data['range']
  else
    let l:range = {}
  endif

  let l:data = l:parsed_data['contents']

  call langserver#hover#display(l:range, l:data)
endfunction

function! langserver#hover#request() abort
  return langserver#client#send(langserver#util#get_lsp_id(), {
        \ 'method': 'textDocument/hover',
        \ 'params': langserver#util#get_text_document_position_params(),
        \ 'on_notification': {
          \ 'callback': function('langserver#hover#callback'),
          \ },
        \ })
endfunction

function! langserver#hover#display(range, data) abort
  if !empty(a:range)
    let s:my_last_highlight = matchaddpos('WarningMsg', langserver#highlight#matchaddpos_range(a:range))
  endif

  let l:hover_string = ''
  for l:explanation in a:data
    let l:hover_string .= printf("%s: %s\n",
          \ l:explanation['language'],
          \ l:explanation['value'],
          \ )
  endfor

  echo l:hover_string

  return timer_start(3000, function('s:delete_highlight'))
endfunction

function! s:delete_highlight() abort
  silent! call matchdelete(s:my_last_highlight)
endfunction

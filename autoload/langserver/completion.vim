function! langserver#completion#callback(id, data, event) abort
  let l:parsed_data = langserver#callbacks#data(a:id, a:data, a:event)
  if l:parsed_data == {}
    return
  endif

  " {'isIncomplete': bool, 'items': [CompletionItems]}
  let l:completion_items = l:parsed_data['items']

endfunction

function! langserver#completion#request(...) abort
  return langserver#client#send(langserver#util#get_lsp_id(), {
        \ 'method': 'textDocument/completion',
        \ 'params': langserver#util#get_text_document_position_params(),
        \ })
endfunction

let s:CompletionItemKind = {
      \ 'Text': 1,
      \ 'Method': 2,
      \ 'Function': 3,
      \ 'Constructor': 4,
      \ 'Field': 5,
      \ 'Variable': 6,
      \ 'Class': 7,
      \ 'Interface': 8,
      \ 'Module': 9,
      \ 'Property': 10,
      \ 'Unit': 11,
      \ 'Value': 12,
      \ 'Enum': 13,
      \ 'Keyword': 14,
      \ 'Snippet': 15,
      \ 'Color': 16,
      \ 'File': 17,
      \ 'Reference': 18
      \ }

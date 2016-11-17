let s:method = 'textDocument/references'

function! langserver#references#transform_reply(message) abort
  " {'bufnr': bufnr('%'), 'lnum': 2, 'col': 8, 'text': 'Testing...', 'type': 'W'},

  let l:location_list = []
  for l:location in a:message
    let l:loc_bufnr = bufnr(langserver#util#get_filename(langserver#util#get_lsp_id(), l:location['uri']))
    let l:loc_line = l:location['range']['start']['line'] + 1
    let l:loc_text = bufnr('%') == l:loc_bufnr ? getline(l:loc_line) : ''

    let l:location_dict = {
          \ 'bufnr': l:loc_bufnr,
          \ 'lnum': l:loc_line,
          \ 'col': l:location['range']['start']['character'] + 1,
          \ 'text': l:loc_text,
          \ 'type': 'x'
          \ }
    call add(l:location_list, l:location_dict)
  endfor

  return l:location_list
endfunction

function! langserver#references#callback(id, data, event) abort
  call langserver#log#callback(a:id, a:data, a:event)

  if type(a:data) != type({})
    return
  endif

  if has_key(a:data, 'response')
    let l:parsed_data = a:data['response']['result']
  else
    return
  endif

  let g:last_response = l:parsed_data

  let l:loc_list = langserver#references#transform_reply(l:parsed_data)

  call langserver#references#display(l:loc_list)
endfunction

function! langserver#references#request() abort
  let l:params = langserver#util#get_text_document_position_params()
  call extend(l:params, {'context': {'includeDeclaration': v:true}})

  return langserver#client#send(langserver#util#get_lsp_id(), {
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

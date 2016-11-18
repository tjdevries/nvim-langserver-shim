let s:symbol_kind = {
    \ 'name': {
      \ 'File': 1,
      \ 'Module': 2,
      \ 'Namespace': 3,
      \ 'Package': 4,
      \ 'Class': 5,
      \ 'Method': 6,
      \ 'Property': 7,
      \ 'Field': 8,
      \ 'Constructor': 9,
      \ 'Enum': 10,
      \ 'Interface': 11,
      \ 'Function': 12,
      \ 'Variable': 13,
      \ 'Constant': 14,
      \ 'String': 15,
      \ 'Number': 16,
      \ 'Boolean': 17,
      \ 'Array': 18,
      \ },
    \ 'number': {
      \ 1: 'File',
      \ 2: 'Module',
      \ 3: 'Namespace',
      \ 4: 'Package',
      \ 5: 'Class',
      \ 6: 'Method',
      \ 7: 'Property',
      \ 8: 'Field',
      \ 9: 'Constructor',
      \ 10: 'Enum',
      \ 11: 'Interface',
      \ 12: 'Function',
      \ 13: 'Variable',
      \ 14: 'Constant',
      \ 15: 'String',
      \ 16: 'Number',
      \ 17: 'Boolean',
      \ 18: 'Array',
      \ },
      \ }


function! langserver#symbol#util#transform_reply(message) abort
  let l:server_name = langserver#util#get_lsp_id()
  let l:qf_list = []

  for l:msg in a:message
    let l:loc_filename = langserver#util#get_filename(l:server_name, l:msg['location']['uri'])
    let l:loc_line = l:msg['location']['range']['start']['line'] + 1
    let l:loc_col = l:msg['location']['range']['start']['character'] + 1

    let l:loc_kind = s:symbol_kind['number'][l:msg['kind']]

    let l:msg_dict = {
          \ 'filename': l:loc_filename,
          \ 'lnum': l:loc_line,
          \ 'col': l:loc_col,
          \ 'pattern': l:msg['name'],
          \ 'text': printf('%10s: %s',
            \ l:loc_kind,
            \ l:msg['name'],
            \ ),
          \ }

    call add(l:qf_list, l:msg_dict)
  endfor

  return l:qf_list
endfunction


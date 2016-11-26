function! s:give_word_at_position(context) abort
  "  'params': 
  "      {'uri': 'file:///home/tj/Downloads/example-ocaml-merlin/src/main.ml',
  "      'position': {'character': 9, 'line': 6}
  "      }
  if !has_key(a:context, 'uri') || !has_key(a:context, 'position')
    " TODO: Log an error?
    return
  endif

  let l:loc_bufnr = bufnr(langserver#util#get_filename(langserver#util#get_lsp_id(), a:context.uri))
  let l:loc_line = langserver#util#get_line(l:loc_bufnr, a:context.uri, a.position.line - 1)

  call langserver#log#log('error', 'LOC LINE: ' . l:loc_line, v:true)
endfunction


let s:register_callbacks = {
      \ 'reason.client.giveWordAtPosition': function('s:give_word_at_position'),
      \ }

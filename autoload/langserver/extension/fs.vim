""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extension to handle "fl/#" commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Respond with the full file reading
function! langserver#extension#fs#readFille(filename) abort
  echom a:filename

  " let l:text = join(readfile(a:filename), "\n")
  " echo system(['base64', join(readfile('/home/tj/test/lsp.py'), "\n")])
  if filereadable(a:filename)
    return system(['base64', a:filename])
  else
    call langserver#log#log('error', 'Unable to read file: ' . a:filename)
    return ''
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extension to handle "fl/#" commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Respond with the full file reading
function! langserver#extension#fs#readFille(filename) abort
  echom a:filename

  return join(readfile(a:filename), "\n")
endfunction

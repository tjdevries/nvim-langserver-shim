let s:langserver_executabe = 'langserver-go'

""
" Get the default command for starting the server
function! langserver#default#cmd()
  if has_key(g:langserver_executables, &filetype)
    return g:langserver_executables[&filetype]
  else
    return [-1]
  endif
endfunction

let s:langserver_executabe = 'langserver-go'

""
" Get the default command for starting the server
function! langserver#default#cmd() abort
  let l:bad_cmd = [-1]

  if has_key(g:langserver_executables, &filetype)
    let l:tmp_cmd = g:langserver_executables[&filetype]['cmd']

    if type(l:tmp_cmd) == type([])
      return l:tmp_cmd
    elseif type(l:tmp_cmd) == type(function('tr'))
      let l:result = l:tmp_cmd()
      if type(l:result) == type([])
        return l:result
      endif
    endif
  endif

  " If we didn't return anything, there was an error.
  echoerr 'Please consult the documentation for how to configure the langserver'
  return l:bad_cmd
endfunction

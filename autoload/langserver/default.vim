let s:langserver_executabe = 'langserver-go'

""
" Get the default command for starting the server
function! langserver#default#cmd() abort
  let l:bad_cmd = [-1]

  if has_key(g:langserver_executables, &filetype)
      let l:tmp_cmd = g:langserver_executables[&filetype]['cmd']

      if type(l:tmp_cmd) != type([])
        echoerr 'Make sure your dictionary is structued like: {"filetype": {"cmd": [cmd, list, here]}}'
        return l:bad_cmd
      endif

      return l:tmp_cmd
    return 
  else
    return l:bad_cmd
  endif
endfunction

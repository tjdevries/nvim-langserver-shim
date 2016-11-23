let s:langserver_executabe = 'langserver-go'

""
" Get the default command for starting the server
function! langserver#default#cmd(...) abort
  if a:0 > 0
    let l:filetype_key = langserver#util#get_executable_key(a:1)
  else
    let l:filetype_key = langserver#util#get_executable_key(&filetype)
  endif

  let l:bad_cmd = [-1]

  if has_key(g:langserver_executables, l:filetype_key)
    " Has to be uppercase because of function naming
    " Sorry for mixed case :/
    let l:TmpCmd = g:langserver_executables[l:filetype_key]['cmd']

    if type(l:TmpCmd) == type([])
      return l:TmpCmd
    elseif type(l:TmpCmd) == type(function('tr'))
      let l:result = l:TmpCmd()
      if type(l:result) == type([])
        return l:result
      endif
    endif
  endif

  " If we didn't return anything, there was an error.
  echoerr 'Please consult the documentation for how to configure the langserver'
  return l:bad_cmd
endfunction

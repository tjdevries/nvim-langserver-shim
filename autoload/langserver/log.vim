let s:log_file = expand('~/langserver-vim.log')

let s:current_level = 4
let s:log_level_map = {
      \ 'error': 0,
      \ 'warning': 1,
      \ 'info': 2,
      \ 'debug': 3,
      \ 'micro': 4,
      \ }

let s:clear_log = v:true

""
" Logging helper
function! langserver#log#log(level, message, ...) abort
  if s:clear_log
    call writefile([], s:log_file, '')
    let s:clear_log = v:false
  endif

  if a:0 > 0
    let l:echo_choice = a:1
  else
    let l:echo_choice = v:false
  endif

  let l:numeric_level = s:log_level_map[a:level]

  if type(a:message) == type('')
    let l:msg = [a:message]
  elseif type(a:message) == type({})
    let l:msg = [string(a:message)]
  elseif type(a:message) != type([])
    " TODO: Handle other types of messages?
  else
    let l:msg = a:message
  endif

  let l:final_msg = []
  for l:item in l:msg
    call add(l:final_msg, printf('%5s: %s',
          \ a:level,
          \ l:item,
          \ ))
  endfor


  if l:numeric_level < s:current_level
    if l:echo_choice
      echom string(l:final_msg)
    endif

    call writefile(l:final_msg, s:log_file, 'a')
  endif
endfunction

""
" Log response helper
function! langserver#log#response(id, data, event) abort
  let g:last_response = a:data

  if type(a:data) != type({})
    call langserver#log#log('debug',
          \ printf('(%3s:%15s): %s',
          \ a:id,
          \ a:event,
          \ string(a:data)
          \ ),
          \ langserver#util#debug(),
          \ )
    return
  endif

  if has_key(a:data, 'response') && has_key(a:data, 'request')
        \ && has_key(a:data.response, 'result') && has_key(a:data.request, 'method')
    call langserver#log#log('debug',
          \ printf('(%3s:%15s): Response -> M(%20s), D(%s)',
            \ a:id,
            \ a:event,
            \ string(a:data.request.method),
            \ string(a:data.response.result),
            \ ),
          \ langserver#util#debug(),
          \ )
  elseif has_key(a:data, 'request') && type(a:data.request) == type({})
    call langserver#log#log('debug',
          \ printf('(%3s:%15s): Request  -> M(%20s), D(%s)',
            \ a:id,
            \ a:event,
            \ string(a:data.request.method),
            \ string(a:data.request.params),
            \ ),
          \ langserver#util#debug(),
          \ )
  else
    call langserver#log#log('debug',
          \ printf('(%3s:%15s): Unknown  -> D(%s)',
            \ a:id,
            \ a:event,
            \ string(a:data),
            \ ),
          \ langserver#util#debug(),
          \ )
  endif
endfunction

""
" Log only at debug level
function! langserver#log#callback(id, data, event) abort
  call langserver#log#log('debug',
        \ printf('(%3s:%15s): %s',
          \ a:id,
          \ a:event,
          \ string(a:data)
          \ ),
        \ v:false
        \ )
endfunction

""
" Log a request from the server
function! langserver#log#server_request(id, data, event) abort
  call langserver#log#log('info',
        \ printf('(%3s:%15s): %s',
        \ a:id,
        \ a:event,
        \ string(a:data)
        \ ))
endfunction

function! langserver#log#pretty_print(json_dict) abort
  " TODO: Get pretty printing of json dictionaries if possible
  let g:my_var = system([
        \ 'echo',
        \ shellescape(g:last_response[3]),
        \ '|',
        \ 'python', '-m', 'json.tool',
        \ ])
endfunction

let s:message_type = {
      \ 'name': {
        \ 'error': 1,
        \ 'warning': 2,
        \ 'info': 3,
        \ 'log': 4,
        \ },
      \ 'number': {
        \ 1: 'error',
        \ 2: 'warning',
        \ 3: 'info',
        \ 4: 'log',
        \ },
      \ }

function! langserver#window#handle#showMessage(message) abort
  let l:type = a:message['type']
  let l:message = a:message['message']

  echo l:type | echo l:message
endfunction

function! langserver#window#handle#logMessage(message) abort
  let l:type = a:message['type']
  let l:message = a:message['message']

  " Not sure if this will work exactly.
  " Might have to do another mapping here.
  call langserver#log#log(l:type, l:message)
endfunction

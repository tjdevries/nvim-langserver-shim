
function! s:dict_lock() dict
  let self.locked = v:true
endfunction

function! s:dict_unlock() dict
  let self.locked = v:false
endfunction

function! langserver#lock#semaphore() abort
  let l:ret = {}
  let l:ret.locked = v:false
  let l:ret.lock = function('s:dict_lock')
  let l:ret.unlock = function('s:dict_unlock')
  return l:ret
endfunction

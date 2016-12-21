
function! s:dict_lock() dict
  let self.locked = v:true
endfunction

function! s:dict_unlock() dict
  let self.locked = v:false
endfunction

function! s:set_id(job_id) dict
  let self.id = a:job_id
endfunction

function! s:get_id() dict
  return self.id
endfunction

function! langserver#lock#semaphore() abort
  let l:ret = {
        \ 'id': -1,
        \ 'locked': v:false,
        \ }
  let l:ret.lock = function('s:dict_lock')
  let l:ret.unlock = function('s:dict_unlock')
  let l:ret.set_id = function('s:set_id')
  let l:ret.get_id = function('s:get_id')
  return l:ret
endfunction

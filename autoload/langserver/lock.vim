let s:unlocked_id = -1

function! s:dict_lock(job_id) dict
  if self.locked == v:false
    let self.locked = v:true
    let self.id = a:job_id
    return v:true
  else
    return v:false
  endif
endfunction

function! s:dict_unlock() dict
  let self.id = s:unlocked_id
  let self.locked = v:false
endfunction

function! s:get_id() dict
  return self.id
endfunction

function! s:take_lock(job_id) dict
  " If we're locked, kill the other job
  " And set ourselves to be the current job.
  if self.locked
    " TODO: Don't actually want to stop the whole server...
    " I just want to stop the current request. Maybe a send cancel request
    " would be good enough. We will see.
    " call langserver#job#stop(self.id)
    call self.unlock()
  endif

  call self.lock(a:job_id)
endfunction

function! langserver#lock#semaphore() abort
  let l:ret = {
        \ 'id': s:unlocked_id,
        \ 'locked': v:false,
        \ }
  let l:ret.lock = function('s:dict_lock')
  let l:ret.unlock = function('s:dict_unlock')
  let l:ret.get_id = function('s:get_id')
  let l:ret.take_lock = function('s:take_lock')
  return l:ret
endfunction

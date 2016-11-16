
function! s:translate_range(range) abort
   return [
            \ a:range['start']['line'] + 1,
            \ a:range['start']['character'] + 1,
            \ a:range['end']['character'] - a:range['start']['character']
            \ ]
endfunction

""
" Convert a range object into a matchaddposd compatible list
function! langserver#highlight#matchaddpos_range(range) abort
   let ret_list = []
   if type(a:range) == type([])
      for r in a:range
         call add(ret_list, s:translate_range(r))
      endfor
   elseif type(a:range) == type({})
      call add(ret_list, s:translate_range(a:range))
   endif

   return ret_list
endfunction

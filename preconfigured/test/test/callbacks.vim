function! s:test_function(context) abort
  return 'tested ' . a:context['var'] . '!' 
endfunction

function! Preconfigured_test_test() abort
  return {
        \ 'method_name': function('s:test_function'),
        \ }
endfunction

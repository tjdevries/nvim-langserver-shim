" TODO: Add this.
" TODO: Decide whether to create request in command or here
function! langserver#goto#request() abort
endfunction

function! s:goto_defintion(name, uri, range_dict, options)
  " TODO: Case sensitivity?
  if a:uri !=? langserver#util#get_uri(a:name, expand('%'))
    " TODO: Open a new file
  endif


  " Functions to Handle moving around:
  " Saving:
  "     winsaveview / winrestview
  " Moving:
  "     cursor
  "           call cursor(
  "                 \ range['start']['line'],
  "                 \ range['start']['character'],
  "                 \ )
  "     normal <line>G<column>|
  " This keeps the jumplist intact.
  execute(printf("norm! %sG%s|",
        \ a:range_dict['start']['line'] + 1,
        \ a:range_dict['start']['character'] + 1,
        \ ))
endfunction


""
" Handle the response to a go to request
"
" @param name (str): Name of the server who sent the response
" @param location (Location?[]): Location or list of Locations
" @param errors (?)
" @param options: Open in split, etc.
function! langserver#goto#response(name, location, ...)
  if a:0 > 1
    let response_errors = a:1
    let l:options = a:2
  elseif a:0 == 1
    let response_errors = a:1
    let l:options = v:false
  else
    let response_errors = v:false
    let l:options = v:false
  endif

  " TODO: Handle goto response errors
  if type(a:location) == type([])
    " TODO: Handle lists of locations
  else
    " This means we have only one location to go to
    call s:goto_defintion(a:name, a:location['uri'], a:location['range'], l:options)
  endif
endfunction

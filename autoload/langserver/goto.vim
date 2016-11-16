function! s:on_definition_request(id, data, event) abort
   let parsed = langserver#util#parse_message(a:data)
   let g:last_response = parsed

   if parsed['type'] ==# 'result'
      let data = parsed['data']['textDocument/definition'][0]
   else
      return
   endif

   if langserver#util#debug()
      echom string(a:data)
      echom 'Definition data is: ' . string(parsed)
    endif

    " {'data':
    "     {'textDocument/definition':
    "         [
    "             {'uri': 'file:///home/tj/go/src/github.com/sourcegraph/go-langserver/langserver/util.go',
    "              'range': {
    "                 'end': {'character': 29, 'line': 15},
    "                 'start': {'character': 23, 'line': 15}}
    "             }
    "         ]
    "      },
    "      'type': 'result'}
    call langserver#goto#goto_defintion(a:id, data['uri'], data['range'], {})
endfunction

function! langserver#goto#request(name) abort
  call lsp#lspClient#send(a:name, {
          \ 'method': 'textDocument/definition',
          \ 'params': {
             \ 'textDocument': langserver#util#get_text_document_identifier(a:name),
             \ 'position': langserver#util#get_position(),
          \ },
          \ 'on_notification': function('s:on_definition_request'),
          \ 'on_stderr': function('s:on_definition_request'),
          \ })
endfunction

function! langserver#goto#goto_defintion(name, uri, range_dict, options) abort
  " TODO: Case sensitivity?
  if a:uri !=? langserver#util#get_uri(a:name, expand('%'))
    let l:file_name = langserver#util#get_filename(a:name, a:uri)
    let l:file_bufnr = bufnr(l:file_name)

    if l:file_bufnr > 0
      execute(':silent buffer ' . bufnr(l:file_name))
    else
      execute('silent edit ' . l:file_name)
    endif

    " Print an informative message
    file!
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
  " echom printf('norm! %sG%s|',
  "       \ a:range_dict['start']['line'] + 1,
  "       \ a:range_dict['start']['character'] + 1,
  "       \ )
  echom 'Am i getting here'
  execute(printf('norm! %sG%s|',
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
"   TODO: Open in split
"   TODO: ...
function! langserver#goto#response(name, location, ...) abort
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
    call langserver#goto#goto_defintion(a:name, a:location['uri'], a:location['range'], l:options)
  endif
endfunction

""
" Initialize request. The first request from the client to the server
"
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#initialize-request
function! langserver#initialize#request() abort
  let l:return_dict = {}

  " TODO: Determine what to do about starting vs connecting
  " TODO: Add to dictionary if present
  let l:process_id = 0

  " TODO: Setting a project root
  " TODO: Add to dictionary if present
  let l:root_path = ''

  " TODO: Add to dictionary if present
  let l:initialization_options = '?'

  let l:return_dict['capabilities'] = langserver#initialize#get_client_capabilities()


  return l:return_dict
endfunction

""
" Return the capabilities of the client
"
" Seems to just be empty according to the spec
function! langserver#initialize#get_client_capabilities() abort
  return {}
endfunction

""
" Handle the response of the server.
" This message details the capabilities of the language server.
"
" @param name (string): The name of the server
" @param response (dict): The dictionary detailing the capabilities of the server
function! langserver#initialize#response(name, response) abort
  if has_key(a:response, 'textDocumentSync')
    call langserver#capabilities#set_test_document_sync_kind(a:name, a:response['textDocumentSync'])
  endif

  " TODO: Handle the rest of the capabilities
endfunction

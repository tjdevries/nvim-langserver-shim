

""
" Content helper
"
" @param id (int): The id is for TODO
" @param method (str): A string defining the method name
" @param params (dict): The parameters to be loaded into the message
"
" @returns json encoded message content
function! langserver#message#content(id, method, params) abort
  let message_content = {
        \ 'jsonrpc': g:langserver_configuration['json_rpc_version'],
        \ 'id': a:id,
        \ 'method': a:method,
        \ 'params': a:param,
        \ }

  return json_encode(message_content)
endfunction

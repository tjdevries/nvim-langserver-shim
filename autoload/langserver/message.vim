

""
" Content helper
"
" @param id (int): The id is for TODO
" @param method (str): A string defining the method name
" @param params (dict): The parameters to be loaded into the message
"
" @returns (dict): message content
function! langserver#message#content(id, method, params) abort
  return {
        \ 'jsonrpc': g:langserver_configuration['json_rpc_version'],
        \ 'id': a:id,
        \ 'method': a:method,
        \ 'params': a:param,
        \ }
endfunction

""
" Message sender
"
function! langserver#message#send(name, header, content) abort
  " Call the remote plugin to send this
endfunction

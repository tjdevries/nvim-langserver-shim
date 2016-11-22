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

function! langserver#initialize#callback(id, data, event) abort
  call langserver#initialize#response(a:id, a:data.response.result)

  call langserver#log#log('info', 'Succesfully connected to: ' . string(a:id), v:true)
endfunction

""
" Handle the response of the server.
" This message details the capabilities of the language server.
"
" @param name (string): The name of the server
" @param response (dict): The dictionary detailing the capabilities of the server
function! langserver#initialize#response(name, response) abort
  if has_key(a:response, 'textDocumentSync')
    call langserver#capabilities#set_test_document_sync(a:name, a:response['textDocumentSync'])
  endif

  if has_key(a:response, 'hoverProvider')
    call langserver#capabilities#set_hover_provider(a:name, a:response['hoverProvider'])
  endif

  if has_key(a:response, 'completionProvider')
    let l:complete_opt_resolve = get(a:response['completionProvider'], 'resolveProvider', v:false)
    let l:complete_opt_trigger = get(a:response['completionProvider'], 'triggerCharacters', [])
    call langserver#capabilities#set_completion_provider(a:name, l:complete_opt_resolve, l:complete_opt_trigger)
  endif

  if has_key(a:response, 'signatureHelpProvider')
    let l:signature_help_resolve = get(a:response['signatureHelpProvider'], 'resolveProvider', v:false)
    call langserver#capabilities#set_signature_help_provider(a:name, l:signature_help_resolve)
  endif

  if has_key(a:response, 'definitionProvider')
    let l:definitionProviderValue = get(a:response, 'definitionProvider', v:false)

    call langserver#capabilities#set_definition_provider(a:name, l:definitionProviderValue)
  endif

  if has_key(a:response, 'referencesProvider')
    let l:referencesProviderValue = get(a:response, 'referencesProvider', v:false)

    call langserver#capabilities#set_references_provider(a:name, l:referencesProviderValue)
  endif

  if has_key(a:response, 'documentHighlightProvider')
    let l:documentHighlightProviderValue = get(a:response, 'documentHighlightProvider', v:false)
  
    call langserver#capabilities#set_document_highlight_provider(a:name, l:documentHighlightProviderValue)
  endif

  if has_key(a:response, 'documentSymbolProvider')
    let l:documentSymbolProviderValue = get(a:response, 'documentSymbolProvider', v:false)
  
    call langserver#capabilities#set_document_symbol_provider(a:name, l:documentSymbolProviderValue)
  endif

  if has_key(a:response, 'workspaceSymbolProvider')
    let l:workspaceSymbolProviderValue = get(a:response, 'workspaceSymbolProvider', v:false)
  
    call langserver#capabilities#set_workspace_symbol_provider(a:name, l:workspaceSymbolProviderValue)
  endif

  if has_key(a:response, 'codeActionProvider')
    let l:codeActionProviderValue = get(a:response, 'codeActionProvider', v:false)
  
    call langserver#capabilities#set_code_action_provider(a:name, l:codeActionProviderValue)
  endif

  " TODO: Code lens provider
  if has_key(a:response, 'codeLensProvider')
    let l:codeLensProviderValue = get(a:response['codeLensProvider'], 'resolveProvider', v:false)
  
    call langserver#capabilities#set_code_lens_provider(a:name, l:codeLensProviderValue)
  endif

  if has_key(a:response, 'documentFormattingProvider')
    let l:documentFormattingProviderValue = get(a:response, 'documentFormattingProvider', v:false)
  
    call langserver#capabilities#set_document_formatting_provider(a:name, l:documentFormattingProviderValue)
  endif

  if has_key(a:response, 'documentRangeFormattingProvider')
    let l:documentRangeFormattingProviderValue = get(a:response, 'documentRangeFormattingProvider', v:false)
  
    call langserver#capabilities#set_document_range_formatting_provider(a:name, l:documentRangeFormattingProviderValue)
  endif

  if has_key(a:response, 'documentOnTypeFormattingProvider')
    let l:document_type_formatting_first = get(a:response['documentOnTypeFormattingProvider'], 'firstTriggerCharacter')
    let l:document_type_formatting_more = get(a:response['documentOnTypeFormattingProvider'], 'moreTriggerCharacter')

    call langserver#capabilities#set_document_on_type_formatting_provider(a:name,
          \ l:document_type_formatting_first,
          \ l:document_type_formatting_more)
  endif

  if has_key(a:response, 'renameProvider')
    let l:renameProviderValue = get(a:response, 'renameProvider', v:false)
  
    call langserver#capabilities#set_rename_provider(a:name, l:renameProviderValue)
  endif
endfunction

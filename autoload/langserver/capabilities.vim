let s:TextDocumentSyncKind = {
      \ 'name': {
        \ 'None': 0,
        \ 'Full': 1,
        \ 'Incremental': 2
        \ },
      \ 'number': {
        \ 0: 'None',
        \ 1: 'Full',
        \ 2: 'Incremental'
        \ },
      \ }

" In case this has been set somehow. Not sure if I want to do it like this,
" but it should guard against anything overwriting this
let g:langserver_capabilities = get(g, 'langserver_capabilities', {})

""
" Makes sure that the dictionary is prepared to record the capabilities of
" server {name}
"
" @param name (str): The name of the server
" @returns dict: The dictionary that is in the configuration dictionary
function! s:prepare_capabiilties(name, ...) abort
  let l:optional_key = v:false
  if a:0 > 0
    let l:optional_key = v:true
    let l:dict_key = a:1
  endif

  if !has_key(g:langserver_capabilities, a:name)
    let g:langserver_capabilities[a:name] = {}
  endif


  if l:optional_key
    " Get an exisiting language server, if necessary.
    let g:langserver_capabilities[a:name][l:dict_key] =
          \ get(g:langserver_capabilities[a:name], l:dict_key, {})

    return g:langserver_capabilities[a:name][l:dict_key]
  else
    return g:langserver_capabilities[a:name]
  endif

endfunction

"------------------- Various setters ------------------------------------------

""
" @param name (str): The name of the server
" @param kind (int): The corresponding document sync kind
function! langserver#capabilities#set_test_document_sync(name, kind) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  " Set the value to a human readable value
  let l:config_dict['textDocumentSync'] = s:TextDocumentSyncKind['number'][a:kind]
endfunction

""
function! langserver#capabilities#set_hover_provider(name, hover_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['hoverProvider'] = a:hover_provider
endif

""
" @param resolve_provider (bool): Provide support for resolves
" @param trigger_characters (list[str]): Characters that trigger completion automatically
"   TODO: Set these to autocommands? maps? how to set it exactly.
function! langserver#capabilities#set_completion_provider(name, resolve_provider, trigger_characters) abort
  let l:config_dict = s:prepare_capabiilties(a:name, 'completionProvider')


  let l:config_dict['resolve_provider'] = a:resolve_provider

  " TODO: Might do the mappings here?
  let l:config_dict['trigger_characters'] = a:trigger_characters
endfunction

""
function! langserver#capabilities#set_signature_help_provider(name, resolve_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['resolve_provider'] = a:resolve_provider
endfunction

""
"
function! langserver#capabilities#set_definition_provider(name, definition_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['definition_provider'] = a:definition_provider
endfunction

""
"
function! langserver#capabilities#set_references_provider(name, references_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['references_provider'] = a:references_provider
endfunction

""
"
function! langserver#capabilities#set_document_highlight_provider(name, document_highlight_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['document_highlight_provider'] = a:document_highlight_provider
endfunction

""
"
function! langserver#capabilities#set_document_symbol_provider(name, document_symbol_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['document_symbol_provider'] = a:document_symbol_provider
endfunction

""
"
function! langserver#capabilities#set_workspace_symbol_provider(name, workspace_symbol_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['workspace_symbol_provider'] = a:workspace_symbol_provider
endfunction

""
"
function! langserver#capabilities#set_code_action_provider(name, code_action_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['code_action_provider'] = a:code_action_provider
endfunction

""
"
function! langserver#capabilities#set_code_lens_provider(name, resolve_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name, 'codeLensProvider')

  let l:config_dict['resolve_provider'] = a:resolve_provider
endfunction

""
"
function! langserver#capabilities#set_document_formatting_provider(name, document_formatting_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['document_formatting_provider'] = a:document_formatting_provider
endfunction

""
"
function! langserver#capabilities#set_document_range_formatting_provider(name, document_range_formatting_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['document_range_formatting_provider'] = a:document_range_formatting_provider
endfunction

""
"
function! langserver#capabilities#set_document_on_type_formatting_provider(name,
      \ first_trigger_character,
      \ more_trigger_character) abort
  let l:config_dict = s:prepare_capabiilties(a:name, 'documentOnTypeFormatting')

  let l:config_dict['first_trigger_character'] = a:trigger_characters
  let l:config_dict['more_trigger_character'] = a:more_trigger_character
endfunction

""
"
function! langserver#capabilities#set_rename_provider(name, rename_provider) abort
  let l:config_dict = s:prepare_capabiilties(a:name)

  let l:config_dict['rename_provider'] = a:rename_provider
endfunction

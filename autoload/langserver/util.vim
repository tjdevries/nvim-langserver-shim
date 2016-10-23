
let s:diagnostic_severity = {
      \ 'Error': 1,
      \ 'Warning': 2,
      \ 'Informatin': 3,
      \ 'Hint': 4,
      \ }


" Basic Json Structures
"
""
" Get a position dictinoary like the position structure
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#position
function! langserver#util#get_position() abort
  return {'line': getline('.'), 'character': col('.')}
endfunction

""
" A range in a text document expressed as (zero-based) start and end positions.
" A range is comparable to a selection in an editor. Therefore the end position is exclusive.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#range
function! langserver#util#get_range(start, end) abort
  " TODO: Make sure that these are the correct relativeness,
  return {'start': a:start, 'end': a:end}
endfunction

""
" Represents a location inside a resource, such as a line inside a text file.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#location
function! langserver#util#get_location(start, end) abort
  return {
        \ 'uri': expand('%'),
        \ 'range': langserver#util#get_range(a:start, a:end)
        \ }
endfunction

""
" Represents a diagnostic, such as a compiler error or warning. Diagnostic objects are only valid in the scope of a resource.
"
" Follows spec: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#diagnostic
"
" @param start (int)
" @param end (int)
" @param message (str)
" @param options (dict): Contiainings items like:
"   @key severity (string): Matching key to s:diagnostic_severity
"   @key code TODO
"   @key source TODO
function! langserver#util#get_diagnostic(start, end, message, options) abort
  let return_dict = {
        \ 'range': langserver#util#get_range(a:start, a:end),
        \ 'messsage': a:message
        \ }

  if has_key(options, 'severity')
    let return_dict['severity'] = options['severity']
  endif

  if has_key(options, 'code')
    let return_dict['code'] = options['code']
  endif

  if has_key(options, 'source')
    let return_dict['source'] = options['source']
  endif

  return return_dict
endfunction

""
" Represents a reference to a command.
" Provides a title which will be used to represent a command in the UI.
" Commands are identitifed using a string identifier and the protocol currently doesn't specify a set of well known commands.
" So executing a command requires some tool extension code.
"
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#command
"
" @param title (str): Title of the command
" @param command (str): The identifier of the actual command handler
" @param arguments (Optional[list]): Optional list of arguments passed to the command
function! langserver#util#get_command(title, command, ...) abort
  let return_dict = {
        \ 'title': a:title,
        \ 'command': a:command,
        \ }

  if a:0 > 1
    let return_dict['arguments'] = a:1
  endif
endfunction

""
" A textual edit applicable to a text document.
"
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#textedit
"
" @param start (int)
" @param end (int)
" @param new_text (string): The string to be inserted. Use an empty string for
" delete
function! langserver#util#get_text_edit(start, end, new_text) abort
  return {
        \ 'range': langserver#util#get_range(a:start, a:end),
        \ 'newText': new_text
        \ }
endfunction

""
" A workspace edit represents changes to many resources managed in the workspace.
"
" Corresponds to: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#workspaceedit
"
" TODO: Figure out a better way to do this.
" @param
function! langserver#util#get_workspace_edit(uri, edit) abort
  let my_dict = {
        \ uri: edit
        \ }
endfunction

" TextDocumentIdentifier

" Text documents are identified using a URI. On the protocol level, URIs are passed as strings. The corresponding JSON structure looks like this:

" interface TextDocumentIdentifier {
"     /**
"      * The text document's URI.
"      */
"     uri: string;
" }
" TextDocumentItem

" New: An item to transfer a text document from the client to the server.
" interface TextDocumentItem {
"     /**
"      * The text document's URI.
"      */
"     uri: string;

"     /**
"      * The text document's language identifier.
"      */
"     languageId: string;

"     /**
"      * The version number of this document (it will strictly increase after each
"      * change, including undo/redo).
"      */
"     version: number;

"     /**
"      * The content of the opened text document.
"      */
"     text: string;
" }
" VersionedTextDocumentIdentifier

" New: An identifier to denote a specific version of a text document.
" interface VersionedTextDocumentIdentifier extends TextDocumentIdentifier {
"     /**
"      * The version number of this document.
"      */
"     version: number;
" }
" TextDocumentPositionParams

" Changed: Was TextDocumentPosition in 1.0 with inlined parameters
" A parameter literal used in requests to pass a text document and a position inside that document.

" interface TextDocumentPositionParams {
"     /**
"      * The text document.
"      */
"     textDocument: TextDocumentIdentifier;

"     /**
"      * The position inside the text document.
"      */
"     position: Position;
" }

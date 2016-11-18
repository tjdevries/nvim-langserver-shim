# nvim-langserver-shim

Shim for the language server protocol developed by Microsoft. The protocol can be found here: https://github.com/Microsoft/language-server-protocol

## Configuration

You will need to put this somewhere that is sourced on startup.

```vim
let g:langserver_executables = {
      \ 'go': {
        \ 'name': 'sourcegraph/langserver-go',
        \ 'cmd': ['langserver-go', '-trace', '-logfile', expand('~/Desktop/langserver-go.log')],
        \ },
      \ }
```

More configuration to come...

## Plans

- [x] Use vim lsp
- [x] Use sourcegraph/langserver-go to test
- [x] Functions to make messages / message dictionaries quickly in Neovim.
- [ ] Implement various actions in (similar to) this order:
    - [x] Initialize
    - [x] Shutdown
    - [x] textDocument/didOpen
    - [x] textDocument/references
    - [x] Go to definition: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#goto-definition-request
    - [x] Hover
    - [x] Find references: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#find-references-request
    - [ ] Highlights:
    - [ ] Completion:
        - [ ] Then deoplete source for completion

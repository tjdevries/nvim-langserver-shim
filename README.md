# nvim-langserver-shim

# NOTICE

Hi everyone, Thanks for all the support this plugin has received. If you like it, consider giving feedback and/or help, patches and review to https://github.com/neovim/neovim/pull/6856 , where I'll be working on incorporating this into Neovim.

Once that is merged, I'll probably just delete everything inside the repository (you can go back in history if you'd like it :) ) and point to Neovim's documentation.

Thanks

## Old info

Shim for the language server protocol developed by Microsoft. The protocol can be found here: https://github.com/Microsoft/language-server-protocol

## Configuration

First you need to install a language server. An example of installing one might be:

```shell
$ go get github.com/sourcegraph/go-langserver/langserver/cmd/langserver-go
```

A more complete set of language servers can be found here: https://github.com/Microsoft/language-server-protocol/wiki/Protocol-Implementations

You will need to put this somewhere that is sourced on startup.

```vim
let g:langserver_executables = {
      \ 'go': {
        \ 'name': 'sourcegraph/langserver-go',
        \ 'cmd': ['langserver-go', '-trace', '-logfile', expand('~/Desktop/langserver-go.log')],
        \ },
      \ }
```

To start the language server, run the command:

```vim
:LSPStart
```

After starting the language server, you should be able to run commands like:

```vim
:LSPGoto
:LSPHover
```

and some more to come.

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

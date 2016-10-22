# nvim-langserver-shim

Shim for the language server protocol developed by Microsoft. The protocol can be found here: https://github.com/Microsoft/language-server-protocol


## Sample Process

![Sample Process](./docs/basic_sequence.png)

## Plans

- Use `jsonrpc` from `vscode-languageserver-node`.
- Document the nvim api -> microsoft protocol
    - Allow for different implementations of the nvim side?
- Implement various actions in (similar to) this order:
    - Go to definition: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#goto-definition-request
    - Find references: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#find-references-request
    - Highlights:
    - Deoplete source for completion

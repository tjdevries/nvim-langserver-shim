

"""
I was actually thinking we might even be able to find an easier way for people to implement lsp clients,
at least if python is a valid plugin language for the editor.

Steps:
    - Create a LSP client in Python (A lot of that is done).
    - Register known callbacks for the editor
"""

import time
from queue import Empty

import neovim

from LSP import util


def nvim_get_position(nvim):
    return {
        'line': nvim.line,
        'character': nvim.col
    }


@neovim.plugin
class NeovimLSP:
    # Not sure exactly what args you would pass into this yet
    def __init__(self, client, others):
        self.nvim = neovim.attach()
        self.client = client

        # Create a mapping in Vim for the client
        self.nvim.command('nnoremap <leader>lh :LSPHover <args>')

        self.supported_topics = [
            'textDocument/hover',
        ]

    @neovim.command("LSPHover", nargs='*')
    def textDocument_hover_request(self, args):
        callback_args = {'TODO': 'TODO'}
        self.client.hover(
            callback_args,
            'textDocument/hover',
            text_document=self.nvim.command('expand("%")'),
            position=nvim_get_position(self.nvim)
        )

    def get_textDocument_hover_args(self):
        return {'client': 'neovim'}

    def textDocument_hover_callback(self, lsp_message: dict, callback_data: dict):
        self.nvim.command('call langserver#goto#response({0}, {1}, {2})'.format(
            util.uri_to_path(lsp_message['result'][0]['uri']),
            lsp_message['result'][0]['range']['start']['line'],
            lsp_message['result'][0]['range']['start']['character'],
        ))

    # Could also implement common helper functions
    # ... which could be used in the client manager
    def get_file_name(self):
        return self.nvim.command('expand("%")')


class LspClientManager():
    def __init__(self):
        # Initializing code ...
        pass

    def get_plugin(self, plugin_class, **kwargs):
        # Register the plugin, or create it here as well
        return plugin_class(**kwargs)

    # Other code here

    def response_handler(self, plugin, response_queue):
        while True:
            try:
                response, callback_args = response_queue.get_nowait()

                method = callback_args['request']['method']
                if method in plugin.supported_topics:
                    # Run the corresponding callback
                    getattr(plugin, method.rplace('/', '_') + '_callback')(response, callback_args)
                else:
                    print(callback_args['request']['method'])

            except Empty:
                pass
            except Exception as err:
                print("Error handling reponse %s with callback args %s, err: %s" %
                      (response, callback_args, err))
                print(err)

        time.sleep(.05)

    # More code here

    def textDocument_hover_request(self, plugin, client):
        client.hover(
            plugin.get_textDocument_hover_args(),
            plugin.get_textDocumentPositionParams(),
            plugin.get_position(),
        )

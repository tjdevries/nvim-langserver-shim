from .base import  Base


class Source(Base):
    def __init__(self, nvim):
        super(Source, self).__init__(nvim)

        self.nvim = nvim
        self.name = 'langserver'
        self.mark = '[LSP]'

    def on_event(self, context, filename=''):
        pass

    def gather_candidates(self, context):
        user_input = context['input']
        filetype = context.get('filetype', '')
        complete_str = context['complete_str']

        return [
            {
                'word': user_input + '_hello',
            }
        ]

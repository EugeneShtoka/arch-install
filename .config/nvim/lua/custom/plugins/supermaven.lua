return {
  'supermaven-inc/supermaven-nvim',
  event = 'InsertEnter',
  opts = {
    keymaps = {
      accept_suggestion = '<Tab>',
      clear_suggestion = '<C-]>',
      accept_word = '<C-j>',
    },
    ignore_filetypes = { 'TelescopePrompt' },
    color = {
      suggestion_color = '#5c6370',
      cterm = 244,
    },
    disable_inline_completion = true, -- blink.cmp handles display via supermaven_blink source
    disable_keymaps = false,
  },
}

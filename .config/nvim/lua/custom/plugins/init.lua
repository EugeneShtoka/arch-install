-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  { 'tpope/vim-dadbod' },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    keys = {
      { '<leader>d', group = '[D]atabase' },
      { '<leader>dt', '<cmd>DBUIToggle<cr>',        desc = '[D]atabase [T]oggle UI' },
      { '<leader>da', '<cmd>DBUIAddConnection<cr>',  desc = '[D]atabase [A]dd connection' },
      { '<leader>df', '<cmd>DBUIFindBuffer<cr>',     desc = '[D]atabase [F]ind buffer' },
      { '<leader>dr', '<cmd>DBUIRenameBuffer<cr>',   desc = '[D]atabase [R]ename buffer' },
      {
        '<F9>',
        function()
          local dbui_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dbui' then
              dbui_win = win
              break
            end
          end
          if dbui_win == nil then
            vim.cmd 'DBUIToggle'
          elseif vim.api.nvim_get_current_win() ~= dbui_win then
            vim.api.nvim_set_current_win(dbui_win)
          end
        end,
        desc = 'Database focus UI',
      },
      {
        '<S-F9>',
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dbui' then
              vim.cmd 'DBUIToggle'
              return
            end
          end
        end,
        desc = 'Database close UI',
      },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}

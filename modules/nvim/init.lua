-- NOTE: init.lua gets ran before anything else.

require("options")
require("keymaps")

-- [[ Neovide ]]
if vim.g.neovide then
  vim.o.guifont = "Cascadia Code:h14"
  vim.g.neovide_opacity = 0.90
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
end

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require('plugins')
require('lze').load({
  {
    "repl",
    ft = {"python", "lua", "scala"},
    after = function(_)
      require("repl").setup({
          execute_on_send = true,
          vsplit = false,
      })
      local repl = require('repl')
      vim.keymap.set("n", "<localleader>rm", function() repl.send_statement_definition() end, { desc = "Send semantic unit to REPL"})

      vim.keymap.set("v", "<localleader>rm", function() repl.send_visual_to_repl() end, { desc = "Send visual selection to REPL"})

      vim.keymap.set("n", "<localleader>rb", function() repl.send_buffer_to_repl() end, { desc = "Send entire buffer to REPL"})

      vim.keymap.set("n", "<localleader>rx", function() repl.toggle_execute() end, { desc = "Automatically execute command in REPL after sent"})

      vim.keymap.set("n", "<localleader>rs", function() repl.toggle_vertical() end, { desc = "Create REPL in vertical or horizontal split"})

      vim.keymap.set("n", "<localleader>rw", function() repl.open_repl() end, { desc = "Opens the REPL in a window split"})

      vim.keymap.set({'n', 'v', 'i', 't'}, '<localleader>rt', function() repl.toggle_repl_win() end, { desc = "Opens the REPL in a window split" })
    end,
  },
})

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

vim.cmd([[
  let g:slime_target = "kitty"
  "let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
  "let g:slime_bracketed_paste = 1
]])

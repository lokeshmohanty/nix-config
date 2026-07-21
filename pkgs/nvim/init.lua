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

-- The Nix wrapper injects plugins.lua and the plugin closure. Plain Ubuntu
-- Neovim still gets the core options/keymaps when the wrapper is unavailable.
local has_plugins = pcall(require, 'plugins')
if has_plugins then
  require('lean').setup() -- required only because I use nix
  vim.g.lean_config = { mappings = true }
end

vim.cmd([[
  "let g:slime_target = "kitty"
  let g:slime_target = "tmux"
  let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
  let g:slime_bracketed_paste = 1
  let g:slime_dont_ask_default = 1
]])
vim.keymap.set("n", "<leader>ss", "<Plug>SlimeParagraphSend")
vim.keymap.set("v", "<leader>ss", "<Plug>SlimeRegionSend")


-- NOTE: register an extra lze handler with the spec_field 'for_cat'
-- that makes enabling an lze spec for a category slightly nicer
require("lze").register_handlers(require('nixCatsUtils.lzUtils').for_cat)

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)

if vim.g.neovide then
  vim.o.guifont = "Cascadia Code:h14"
  vim.g.neovide_cursor_vfx_mode = "wireframe"
  vim.g.neovide_opacity = 0.90
end

-- NOTE: These 2 need to be set up before any plugins are loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

require("myConfig.settings")
require("myConfig.lsp")
require("myConfig.plugins")

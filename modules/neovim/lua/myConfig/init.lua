require("myConfig.keymap")
-- require('myConfig.lualine')
require("myConfig.lsp")
require("myConfig.markdown")
require("myConfig.latex")
require("myConfig.treesitter")
require("myConfig.snippets")
require("myConfig.fold")
require("myConfig.terminal")

-- vim.cmd([[ colorscheme retrobox ]])
require("everforest").load()

require("uv").setup({})

vim.cmd([[ let g:tex_flavor = "tex" ]])

-- Completion
-- See: ins-completion
-- require('mini.completion').setup({
--   lsp_completion = {
--     source_func = 'omnifunc'
--   }
-- })

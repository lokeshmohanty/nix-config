
require('myConfig.keymap')
-- require('myConfig.lualine')
require('myConfig.lsp')
require('myConfig.markdown')
require('myConfig.treesitter')
require('myConfig.snippets')

-- vim.cmd([[ colorscheme retrobox ]])
require("everforest").load()



-- Completion
-- See: ins-completion
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc'
  }
})


require('myConfig.keymap')
-- require('myConfig.lualine')
require('myConfig.lsp')
require('myConfig.markdown')
require('myConfig.treesitter')
require('myConfig.snippets')

require("everforest").setup({
  background = "medium",
  transparent_background_level = 1,
})
require("everforest").load()
require("lualine").setup({ options = { theme = "auto" } })

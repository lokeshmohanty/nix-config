vim.opt.runtimepath:append("~/.local/nvim-treesitter")
require('nvim-treesitter.configs').setup({
  parser_install_dir = "~/.local/nvim-treesitter",
  ensure_installed = "all" ,
  highlight = { enable = true },
  incremental_selection = { enable = true }, -- default kemaps: gnn, grn, grc, grm
  textobjects = { enable = true },
  indent = { enable = true },
})


vim.opt.runtimepath:append("~/.local/nvim-treesitter")

-- install latex, html for render-markdown
require("nvim-treesitter.configs").setup({
	parser_install_dir = "~/.local/nvim-treesitter",
})

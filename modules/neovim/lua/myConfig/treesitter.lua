vim.opt.runtimepath:append("~/.local/nvim-treesitter")

require("nvim-treesitter.configs").setup({
	parser_install_dir = "~/.local/nvim-treesitter",
})

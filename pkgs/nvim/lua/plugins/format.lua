local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		-- NOTE: download some formatters in lspsAndRuntimeDeps
		-- and configure them here
		lua = { "stylua" },
		nix = { "nixfmt" },
		rust = { "rustfmt" },
		haskell = { "ormolu" },
		-- templ = { "templ" },
		-- Conform will run multiple formatters sequentially
		-- python = { "isort", "black" },
		-- Use a sub-list to run only the first available formatter
		-- javascript = { { "prettierd", "prettier" } },
	},
	-- format_on_save = {
	-- 	timeout_ms = 500,
	-- 	lsp_format = "fallback",
	-- },
})
vim.keymap.set({ "n", "v" }, "<leader>FF", function()
	conform.format({
		lsp_format = "fallback",
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "[F]ormat [F]ile" })


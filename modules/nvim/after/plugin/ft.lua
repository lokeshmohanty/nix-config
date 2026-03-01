--------------------------------
------------- Lua --------------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		vim.cmd.packadd('lazydev.nvim')
		require('lazydev').setup({
			library = {
				{ path = nixCats.nixCatsPath and nixCats.nixCatsPath .. 'lua' or nil, words = { "nixCats" } },
			},
		})
	end,
})

--------------------------------
------------- Typst ------------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typst" },
	callback = function()
		vim.keymap.set("n", "<localleader>p", "<cmd>TypstPreviewToggle<CR>", { desc = "preview" })
	end,
})

--------------------------------
------------- Tex --------------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex" },
	callback = function()
		-- vim.g.vimtex_view_method = 'zathura'

		vim.g.vimtex_view_general_viewer = "okular"
		vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
	end,
})

--------------------------------
------------- Markdown ---------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function()
		if require("zk.util").notebook_root(vim.fn.expand('%:p')) ~= nil then
			local function map(...) vim.api.nvim_buf_set_keymap(0, ...) end
			local opts = { noremap=true, silent=false }
			map("n", "K",           "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			map("n", "<CR>",        "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

			map("n", "<leader>zn",  "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
			map("n", "<leader>zl",  "<Cmd>ZkLinks<CR>", opts)
			map("n", "<leader>zb",  "<Cmd>ZkBacklinks<CR>", opts)
			--map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)

			map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
			map("v", "<leader>znc", ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
			map("v", "<leader>zi",  ":'<,'>ZkInsertLinkAtSelection { title = vim.fn.input('Title: ') }<CR>", opts)
			map("v", "<leader>za",  ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
		end
	end,
})



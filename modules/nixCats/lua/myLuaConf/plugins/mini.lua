require("mini.pairs").setup({})
require("mini.starter").setup({})

-- Mini Files
require("mini.files").setup({})
vim.keymap.set("n", "<leader>,", "<cmd>lua MiniFiles.open()<cr>")
vim.keymap.set("n", "<leader>.", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>")

local show_dotfiles = true
local filter_show = function(fs_entry)
	return true
end
local filter_hide = function(fs_entry)
	return not vim.startswith(fs_entry.name, ".")
end
local toggle_dotfiles = function()
	show_dotfiles = not show_dotfiles
	local new_filter = show_dotfiles and filter_show or filter_hide
	MiniFiles.refresh({ content = { filter = new_filter } })
end
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		-- Tweak left-hand side of mapping to your liking
		vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
	end,
})

-- Mini Sessions
require("mini.sessions").setup({})
local ms = require("mini.sessions")
vim.keymap.set("n", "<leader>mss", function()
	local input = vim.fn.input("Save session as: ")
	ms.write(input)
end)
vim.keymap.set("n", "<leader>msd", function()
	local sessions = {}
	for k, _ in pairs(ms.detected) do
		table.insert(sessions, k)
	end

	vim.ui.select(sessions, { prompt = "Select session to delete:" }, function(choice)
		ms.delete(choice)
	end)
end)

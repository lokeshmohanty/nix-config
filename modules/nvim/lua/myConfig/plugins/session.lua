-- Mini Sessions
require("mini.sessions").setup({})
local ms = require("mini.sessions")
vim.keymap.set("n", "<leader>oss", function()
	local input = vim.fn.input("Save session as: ")
	ms.write(input)
end)
vim.keymap.set("n", "<leader>osd", function()
	local sessions = {}
	for k, _ in pairs(ms.detected) do
		table.insert(sessions, k)
	end

	vim.ui.select(sessions, { prompt = "Select session to delete:" }, function(choice)
		ms.delete(choice)
	end)
end)

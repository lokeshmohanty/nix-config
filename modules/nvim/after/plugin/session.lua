require("mini.sessions").setup({})

local ms = require("mini.sessions")
local SaveSession = function()
  local input = vim.fn.input("Save session as: ")
  ms.write(input)
end
local DeleteSession = function()
  local sessions = {}
  for k, _ in pairs(ms.detected) do
    table.insert(sessions, k)
  end

  vim.ui.select(sessions, { prompt = "Select session to delete:" }, function(choice)
    ms.delete(choice)
  end)
end
vim.keymap.set("n", "<leader>oss", SaveSession)
vim.keymap.set("n", "<leader>osd", DeleteSession)

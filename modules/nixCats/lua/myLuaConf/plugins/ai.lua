return {
  "CopilotChat.nvim",
  for_cat = "general.ai",
  keys = {
    { "<leader>ac", mode = { "n" }, desc = "Toggle Copilot Chat" },
  },
  cmd = { "CopilotChat", "Copilot" },
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd("copilot.lua")
  end,
  after = function(plugin)
    -- Run :copilot auth
    require("copilot").setup({})
    local cs = require("copilot.suggestion")
    vim.keymap.set("i", "<C-l>", cs.accept_line)
    vim.keymap.set("i", "<C-j>", cs.accept_word)

    require("CopilotChat").setup({})
    vim.keymap.set("n", "<leader>ac", "<cmd>CopilotChatToggle<cr>", { desc = "Toggle Copilot Chat" })
  end,
}

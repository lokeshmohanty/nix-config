return {
  "notmuch.nvim",
  cmd = { "Notmuch" },
  -- dir = vim.fn.stdpath("config") .. "/lua/notmuch.nvim",
  after = function()
    vim.cmd.packadd("notmuch.nvim")
    require("notmuch").setup({
      render_html_body = true,
      queries = {
        { name = "   Inbox",         query = "tag:inbox" },
        { name = "📤 Sent today",    query = "tag:sent and date:today" },
        { name = "⚠️ IMPORTANT",     query = "tag:flagged or tag:pr or tag:urgent" },
        { name = "⌛ Overdue (+3d)", query = "tag:inbox and date:..3d" },
        { name = "   Deleted",       query = "tag:del" },
      },
    })
    vim.keymap.set("n", "<leader>on", "<cmd>Notmuch<cr>")
  end,
}

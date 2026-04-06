return {
  "notmuch.nvim",
  cmd = { "Notmuch" },
  dir = vim.fn.stdpath("config") .. "/lua/notmuch.nvim",
  after = function()
    require("notmuch").setup({ render_html_body = true })
    vim.keymap.set("n", "<leader>on", "<cmd>Notmuch<cr>")
  end,
}

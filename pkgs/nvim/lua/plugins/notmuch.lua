return {
  "notmuch.nvim",
  cmd = { "Notmuch" },
  after = function()
    require("notmuch").setup({ render_html_body = true })

    vim.keymap.set("n", "<leader>on", "<cmd>Notmuch<cr>")
  end,
}

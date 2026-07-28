-- =================================================
-- ==== RENDER-MARKDOWN
-- =================================================
vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<CR>", { desc = "preview" })
vim.g.mkdp_filetypes = { "markdown", "mdx" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "mdx", "codecompanion" },
  callback = function()
    vim.g.mkdp_auto_close = 0
    require("render-markdown").setup({
      file_types = { "markdown", "mdx", "codecompanion" },
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      },
    })
  end,
})

-- require("img-clip.nvim").setup({
--   filetypes = {
--     codecompanion = {
--       prompt_for_file_name = false,
--       template = "[Image]($FILE_PATH)",
--       use_absolute_path = true,
--     },
--   },
-- })
--
-- vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", { desc = "Paste image from system clipboard" })

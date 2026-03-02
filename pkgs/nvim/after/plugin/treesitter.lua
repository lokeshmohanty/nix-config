-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`

vim.api.nvim_create_autocmd("FileType", {
  pattern = { '*' },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})


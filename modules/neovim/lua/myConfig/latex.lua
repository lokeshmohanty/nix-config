vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.tex",
  callback = function()
    -- Disable minipairs for "'" as it is being used by snippets
    vim.keymap.set("i", "'", "'", { buffer = true })
  end
})

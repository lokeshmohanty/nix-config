vim.cmd([[
  if exists("b:did_ftplugin")
    finish
  endif
  let b:did_ftplugin = 1
]])

vim.keymap.set("n", "<localleader>p", "<cmd>TypstPreviewToggle<CR>", { desc = "preview" })

-- Only do this when not done yet for this buffer
vim.cmd([[
  if exists("b:did_ftplugin")
    finish
  endif
  let b:did_ftplugin = 1
]])

-- Other commands: TypstPreview document / TypstPreview slide
vim.keymap.set("n", "<localleader>p", "<cmd>TypstPreviewToggle<CR>", { desc = 'preview' })

-- Only do this when not done yet for this buffer
vim.cmd([[
  if exists("b:did_ftplugin")
    finish
  endif
  let b:did_ftplugin = 1
]])

-- Other commands: TypstPreview document / TypstPreview slide
vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<CR>", { desc = 'preview' })


-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*.md",
--   callback = function()
--     vim.opt.wrap = false
--   end
-- })
--
require("render-markdown").setup({
  heading = {
    icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
  },
  completions = { blink = { enabled = true } },
})

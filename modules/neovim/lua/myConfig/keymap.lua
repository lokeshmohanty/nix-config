-- Mini Files
vim.keymap.set('n', '<leader>sd', '<cmd>lua MiniFiles.open()<cr>')

-- Mini Picker
vim.keymap.set('n', '<leader>sf', '<cmd>Pick files<cr>')
vim.keymap.set('n', '<leader>sb', '<cmd>Pick buffers<cr>')
vim.keymap.set('n', '<leader>ss', '<cmd>Pick grep_live<cr>')

-- Mini Sessions
vim.keymap.set('n', '<leader>mss', function()
  local input = vim.fn.input('Create session: ')
  vim.cmd('lua MiniSessions.write(' .. input .. '.vim")')
end, { noremap = true })

vim.keymap.set('n', '<leader>msd', function()
  local input = vim.fn.input('Delete session: ')
  vim.cmd('lua MiniSessions.delete("' .. input .. '.vim")')
end, { noremap = true })

-- Quarto
local quarto = require("quarto")
local runner = require("quarto.runner")
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })

-- Molten
vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten cell", silent = true })
vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })

-- Others
vim.keymap.set('n', '<leader><leader>i', '<cmd>IconPickerYank<cr>')
vim.keymap.set('n', '<leader><leader>p', '<cmd>MarkdownPreviewToggle<cr>')
vim.keymap.set('n', '<leader>sm', '<cmd>Neogit<cr>')

-- Floaterm
vim.keymap.set("n", "<leader>to", ":FloatermNew<cr>",
  { desc = "open new term"})
vim.keymap.set("t", "<leader>to", "<C-\\><C-n>:FloatermNew<cr>",
  { desc = "open new term"})
vim.keymap.set("n", "<leader>tp", ":FloatermPrev<cr>",
  { desc = "goto prev term"})
vim.keymap.set("t", "<leader>tp", "<C-\\><C-n>:FloatermPrev<cr>",
  { desc = "goto prev term"})
vim.keymap.set("n", "<leader>tn", ":FloatermNext<cr>",
  { desc = "goto next term"})
vim.keymap.set("t", "<leader>tn", "<C-\\><C-n>:FloatermNext<cr>",
  { desc = "goto next term"})
vim.keymap.set("n", "<leader>tt", ":FloatermToggle<cr>",
  { desc = "toggle term"})
vim.keymap.set("t", "<leader>tt", "<C-\\><C-n>:FloatermToggle<cr>",
  { desc = "toggle term"})
vim.keymap.set("n", "<leader>tk", ":FloatermKill<cr>",
  { desc = "kill term"})
vim.keymap.set("t", "<leader>tk", "<C-\\><C-n>:FloatermKill<cr>",
  { desc = "kill term"})

-- Yazi (File manager)
vim.keymap.set("n", "<leader>.", ":Yazi<cr>", { desc = "open yazi at current file"})
vim.keymap.set("n", "<leader>,", ":Yazi cwd<cr>", { desc = "open yazi at working directory"})
vim.keymap.set("n", "<leader>-", ":Yazi toggle<cr>", { desc = "resume yazi at last session"})

-- FzfLua
vim.keymap.set('n', '<leader>ff', ':FzfLua files<cr>')
vim.keymap.set('n', '<leader>fb', ':FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>fs', ':FzfLua grep_visual<cr>')

-- Mini Files
vim.keymap.set('n', '<leader>sd', ':lua MiniFiles.open()<cr>')

-- Mini Sessions
vim.keymap.set('n', '<leader>mss', function()
  local input = vim.fn.input('Create session: ')
  vim.cmd('lua MiniSessions.write(' .. input .. '.vim")')
end)
vim.keymap.set('n', '<leader>msd', function()
  local input = vim.fn.input('Delete session: ')
  vim.cmd('lua MiniSessions.delete("' .. input .. '.vim")')
end)

-- Quarto
local quarto = require("quarto")
local runner = require("quarto.runner")
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview)
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })

-- Molten
vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<cr>", { desc = "evaluate operator", silent = true })
vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<cr>", { desc = "open output window", silent = true })
vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<cr>", { desc = "re-eval cell", silent = true })
vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<cr>", { desc = "close output window", silent = true })
vim.keymap.set("n", "<localleader>md", ":MoltenDelete<cr>", { desc = "delete Molten cell", silent = true })
vim.keymap.set("n", "<localleader>mi", ":MoltenInit<cr>", { desc = "Initialize Molten cell", silent = true })
vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<cr>", { desc = "open output in browser", silent = true })

-- External Commands
vim.keymap.set("n", "<leader>ex", ":.w !bash -e<cr>")
vim.keymap.set("n", "<leader>eX", ":%w !bash -e<cr>")
vim.keymap.set("n", "<leader>el", ":.!bash -e<cr>")
vim.keymap.set("n", "<leader>eL", ":% !bash -e<cr>")
vim.keymap.set("n", "<leader>ef", ":lua *G.execute*file_and_show_output()<cr>")
vim.keymap.set("n", "<leader>cx", ":!chmod +x %<cr>")

-- Others
vim.keymap.set('n', '<leader><leader>i', ':IconPickerYank<cr>')
vim.keymap.set('n', '<leader><leader>p', ':MarkdownPreviewToggle<cr>')
vim.keymap.set('n', '<leader><leader>g', ':Neogit<cr>')

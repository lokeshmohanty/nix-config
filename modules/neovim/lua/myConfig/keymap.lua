-- Which-Key
local wk = require("which-key")
wk.add({ "<leader>d", desc = "DAP" })
wk.add({ "<leader>l", desc = "LSP" })

vim.keymap.set("n", "<leader>pp", ":lua require('nabla').popup({border = 'rounded'})<cr>")
vim.keymap.set("n", "<leader>pv", ":lua require('nabla').toggle_virt<cr>")

-- Floaterm
wk.add({ "<leader>t", desc = "Terminal" })
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
vim.keymap.set("n", "<leader>.", ":Yazi<cr>")
vim.keymap.set("n", "<leader>,", ":Yazi cwd<cr>")
vim.keymap.set("n", "<leader>-", ":Yazi toggle<cr>")

-- FzfLua
wk.add({ "<leader>f", desc = "Fuzzy functions" })
vim.keymap.set('n', '<leader>ff', ':FzfLua files<cr>')
vim.keymap.set('n', '<leader>fb', ':FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>fs', ':FzfLua live_grep_native<cr>')
vim.keymap.set('n', '<leader>fg', ':FzfLua grep<cr>')
vim.keymap.set('n', '<leader>fh', ':FzfLua helptags<cr>')
vim.keymap.set('n', '<leader>fB', ':FzfLua builtin<cr>')

-- Mini Files
vim.keymap.set('n', '<leader>sd', ':lua MiniFiles.open()<cr>')

-- Mini Sessions
wk.add({ "<leader>ms", desc = "MiniSessions" })
vim.keymap.set('n', '<leader>mss', function()
  local input = vim.fn.input('Save session as: ')
  MiniSessions.write(input)
end)
vim.keymap.set('n', '<leader>msd', function()
  local sessions, i = { "Delete session: " }, 1
  for k, _ in pairs(MiniSessions.detected) do
    table.insert(sessions, i .. ". " .. k)
  end
  local input = vim.fn.inputlist(sessions)
  MiniSessions.delete(input)
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
wk.add({ "<leader>e", desc = "External commands" })
vim.keymap.set("n", "<leader>ex", ":.w !bash -e<cr>",
  { desc = "run bash on current line" })
vim.keymap.set("n", "<leader>eX", ":%w !bash -e<cr>",
  { desc = "run bash on all lines" })
vim.keymap.set("n", "<leader>el", ":.!bash -e<cr>",
  { desc = "replace bash output on current line" })
vim.keymap.set("n", "<leader>eL", ":% !bash -e<cr>",
  { desc = "replace bash output on all lines" })
vim.keymap.set("n", "<leader>ef", ":lua *G.execute*file_and_show_output()<cr>",
  { desc = "run current file" })
vim.keymap.set("n", "<leader>cx", ":!chmod +x %<cr>",
  { desc = "make current file executable" })

-- Others
wk.add({ "<leader><leader>", desc = "Others" })
vim.keymap.set('n', '<leader><leader>i', ':IconPickerYank<cr>')
vim.keymap.set('n', '<leader><leader>p', ':MarkdownPreviewToggle<cr>')
vim.keymap.set('n', '<leader><leader>g', ':Neogit<cr>')

-- Hide terminal buffers from tabline
-- vim.cmd([[autocmd TermOpen * setlocal nobuflisted]])

-- Keymap
local wk = require("which-key")
wk.add({ "<leader>t", desc = "Terminal" })
vim.keymap.set("n", "<leader>to", ":vsplit | term<cr>", { desc = "open new term" })
vim.keymap.set("t", "<leader>to", "<C-\\><C-n>:term<cr>", { desc = "open new term" })
vim.keymap.set("t", "<leader>tn", "<C-\\><C-n>:ls! R | bn<cr>", { desc = "goto next term" })
vim.keymap.set("t", "<leader>tp", "<C-\\><C-n>:ls! R | bp<cr>", { desc = "goto prev term" })
vim.keymap.set("n", "<leader>tn", ":vsplit | ls! R | bn<cr>", { desc = "open next term in split" })
vim.keymap.set("n", "<leader>tp", ":vsplit | ls! R | bn<cr>", { desc = "open next term in split" })
vim.keymap.set("t", "<leader>tk", "<C-\\><C-n>:bd!<cr>", { desc = "kill term" })
vim.keymap.set(
	"v",
	"<leader>ts",
	"y<C-w><C-w><C-\\><C-n>p<cr><C-\\><C-n><C-w><C-w>",
	{ desc = "send selection to open term" }
)
vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l")
vim.keymap.set("t", "<C-w><C-w>", "<C-\\><C-n><C-w><C-w>")
vim.keymap.set("t", "gt", "<C-\\><C-n>gt")
vim.keymap.set("t", "gT", "<C-\\><C-n>gT")

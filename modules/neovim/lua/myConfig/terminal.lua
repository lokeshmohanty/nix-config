-- Floaterm
vim.cmd([[ let g:floaterm_wintype = 'vsplit' ]])

-- Keymap
local wk = require("which-key")
wk.add({ "<leader>t", desc = "Terminal" })
vim.keymap.set("n", "<leader>to", ":FloatermNew<cr>", { desc = "open new term" })
vim.keymap.set("t", "<leader>to", "<C-\\><C-n>:FloatermNew<cr>", { desc = "open new term" })
vim.keymap.set("n", "<leader>tp", ":FloatermPrev<cr>", { desc = "goto prev term" })
vim.keymap.set("t", "<leader>tp", "<C-\\><C-n>:FloatermPrev<cr>", { desc = "goto prev term" })
vim.keymap.set("n", "<leader>tn", ":FloatermNext<cr>", { desc = "goto next term" })
vim.keymap.set("t", "<leader>tn", "<C-\\><C-n>:FloatermNext<cr>", { desc = "goto next term" })
vim.keymap.set("n", "<leader>tt", ":FloatermToggle<cr>", { desc = "toggle term" })
vim.keymap.set("t", "<leader>tt", "<C-\\><C-n>:FloatermToggle<cr>", { desc = "toggle term" })
vim.keymap.set("n", "<leader>tk", ":FloatermKill<cr>", { desc = "kill term" })
vim.keymap.set("t", "<leader>tk", "<C-\\><C-n>:FloatermKill<cr>", { desc = "kill term" })
vim.keymap.set(
	"v",
	"<leader>ts",
	"y<C-w><C-w><C-\\><C-n>p<cr><C-\\><C-n><C-w><C-w>",
	{ desc = "send selection to term" }
)
vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l")
vim.keymap.set("t", "<C-w><C-w>", "<C-\\><C-n><C-w><C-w>")

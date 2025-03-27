-- use `<cmd>` for silent `:`
-- Which-Key
local wk = require("which-key")
wk.add({ "<leader>d", desc = "DAP" })
wk.add({ "<leader>l", desc = "LSP" })

-- Main
vim.keymap.set("n", "<leader>q", ":bd<cr>")

-- Preview
wk.add({ "<leader>p", desc = "Preview" })
vim.keymap.set("n", "<leader>pp", "<cmd>lua require('nabla').popup({border = 'rounded'})<cr>")
vim.keymap.set("n", "<leader>pv", "<cmd>lua require('nabla').toggle_virt<cr>")
vim.keymap.set("n", "<leader>ps", "<cmd>Markview splitToggle<cr>")
vim.keymap.set('n', '<leader>pm', '<cmd>MarkdownPreviewToggle<cr>')

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
vim.keymap.set("n", "<leader>y", ":Yazi<cr>")

-- FzfLua
wk.add({ "<leader>f", desc = "Fuzzy functions" })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>fB', '<cmd>FzfLua builtin<cr>')
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep_native<cr>')
vim.keymap.set('n', '<leader>fG', '<cmd>FzfLua grep<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua helptags<cr>')
vim.keymap.set('n', '<leader>fm', '<cmd>FzfLua marks<cr>')
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua registers<cr>')
vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua spell_suggest<cr>')
vim.keymap.set('n', 's', ':FzfLua ')

-- Mini Files
vim.keymap.set('n', '<leader>,', '<cmd>lua MiniFiles.open()<cr>')
vim.keymap.set('n', '<leader>.', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>')

local show_dotfiles = true
local filter_show = function(fs_entry) return true end
local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, '.')
end
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Tweak left-hand side of mapping to your liking
    vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
  end,
})

-- Mini Sessions
wk.add({ "<leader>ms", desc = "MiniSessions" })
local ms = require('mini.sessions')
vim.keymap.set('n', '<leader>mss', function()
  local input = vim.fn.input('Save session as: ')
  ms.write(input)
end)
vim.keymap.set('n', '<leader>msd', function()
  local sessions = {}
  for k, _ in pairs(ms.detected) do
    table.insert(sessions, k)
  end

  vim.ui.select(
    sessions,
    { prompt = 'Select session to delete:', },
    function(choice) ms.delete(choice) end
  )
end)



-- Aerial 
-- require("aerial").setup({
--   -- optionally use on_attach to set keymaps when aerial has attached to a buffer
--   on_attach = function(bufnr)
--     -- Jump forwards/backwards with '{' and '}'
--     vim.keymap.set("n", "{", ":AerialPrev<cr>", { buffer = bufnr })
--     vim.keymap.set("n", "}", ":AerialNext<cr>", { buffer = bufnr })
--   end,
-- })
vim.keymap.set("n", "<leader>a", ":AerialToggle!<cr>")


-- Illustrate for handling inkscape
local illustrate = require('illustrate')
local illustrate_finder = require('illustrate.finder')
vim.keymap.set("n", "<leader>is",
  function() illustrate.create_and_open_svg() end,
  { desc = "Create and open a new SVG file with provided name." }
)
vim.keymap.set("n", "<leader>io",
  function() illustrate.open_under_cursor() end,
  { desc = "Open file under cursor (or file within environment under cursor)." }
)
vim.keymap.set("n", "<leader>if",
  function() illustrate_finder.search_and_open() end,
  { desc = "Use telescope to search and open illustrations in default app." }
)
vim.keymap.set("n", "<leader>ic",
  function() illustrate_finder.search_create_copy_and_open() end,
  { desc = "Use telescope to search existing file, copy it with new name, and open it in default app." }
)

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
vim.keymap.set('n', '<leader><leader>i', '<cmd>IconPickerYank<cr>')
vim.keymap.set('n', '<leader><leader>g', '<cmd>Neogit<cr>')

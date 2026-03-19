require('mini.starter').setup()
require('mini.icons').setup()
require('mini.align').setup()
require('mini.indentscope').setup()

-------------------------------------
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()
-------------------------------------

-------------------------------------
require('mini.pairs').setup()
local map_math = function() MiniPairs.map_buf(0, 'i', '$', { action = 'closeopen', pair = '$$' }) end
vim.api.nvim_create_autocmd('FileType', { pattern = {'typst', 'tex'}, callback = map_math })
-------------------------------------

-------------------------------------
-- -- Module mappings. Use `''` (empty string) to disable one.
--   mappings = {
--     -- Main textobject prefixes
--     around = 'a',
--     inside = 'i',
--
--     -- Next/last variants
--     -- NOTE: These override built-in LSP selection mappings on Neovim>=0.12
--     -- Map LSP selection manually to use it (see `:h MiniAi.config`)
--     around_next = 'an',
--     inside_next = 'in',
--     around_last = 'al',
--     inside_last = 'il',
--
--     -- Move cursor to corresponding edge of `a` textobject
--     goto_left = 'g[',
--     goto_right = 'g]',
--   },
require('mini.ai').setup()
-------------------------------------


-------------------------------------
-- Mini Sessions
require("mini.sessions").setup({})

local ms = require("mini.sessions")
local SaveSession = function()
  local input = vim.fn.input("Save session as: ")
  ms.write(input)
end
local DeleteSession = function()
  local sessions = {}
  for k, _ in pairs(ms.detected) do
    table.insert(sessions, k)
  end

  vim.ui.select(sessions, { prompt = "Select session to delete:" }, function(choice)
    ms.delete(choice)
  end)
end
vim.keymap.set("n", "<leader>oss", SaveSession)
vim.keymap.set("n", "<leader>osd", DeleteSession)
-------------------------------------

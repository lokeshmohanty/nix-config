require('mini.starter').setup()
require('mini.icons').setup()
require('mini.surround').setup()

require('mini.pairs').setup()
local map_math = function() MiniPairs.map_buf(0, 'i', '$', { action = 'closeopen', pair = '$$' }) end
vim.api.nvim_create_autocmd('FileType', { pattern = {'typst', 'tex'}, callback = map_math })

require('mini.ai').setup()
--
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

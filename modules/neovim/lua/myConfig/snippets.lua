-- Examples: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets

local ms = require('mini.snippets')
local gen_loader = ms.gen_loader
ms.setup({
  snippets = {
    -- Load custom file with global snippets first
    gen_loader.from_file('~/.config/nvf/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

vim.keymap.set("i", "<C-g><C-j>", function() ms.expand({ match = false }) end)
-- vim.keymap.set("i", "<C-j>", function() ms.expand() end)
-- vim.keymap.set("i", "<C-l>", function() ms.session.jump("next") end)
-- vim.keymap.set("i", "<C-h>", function() ms.session.jump("prev") end)



-- Supertabl like functionality
-- local snippets = require('mini.snippets')
-- local match_strict = function(snips)
--   -- Do not match with whitespace to cursor's left
--   return snippets.default_match(snips, { pattern_fuzzy = '%S+' })
-- end
-- snippets.setup({
--   -- ... Set up snippets ...
--   mappings = { expand = '', jump_next = '', jump_prev = '' },
--   expand   = { match = match_strict },
-- })
-- local expand_or_jump = function()
--   local can_expand = #MiniSnippets.expand({ insert = false }) > 0
--   if can_expand then vim.schedule(MiniSnippets.expand); return '' end
--   local is_active = MiniSnippets.session.get() ~= nil
--   if is_active then MiniSnippets.session.jump('next'); return '' end
--   return '\t'
-- end
-- local jump_prev = function() MiniSnippets.session.jump('prev') end
-- vim.keymap.set('i', '<Tab>', expand_or_jump, { expr = true })
-- vim.keymap.set('i', '<S-Tab>', jump_prev)

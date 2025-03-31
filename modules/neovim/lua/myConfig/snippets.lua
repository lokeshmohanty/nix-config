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

-- Tab for snippet expansion if atleast one character is present before cursor
-- vim.keymap.set('i', '<Tab>', function()
--     local line = vim.api.nvim_get_current_line()
--     local col = vim.api.nvim_win_get_cursor(0)[2]
--     local before_cursor = line:sub(1, col)
--     if before_cursor:match('[%a]') then
--         return ms.expand()
--     else
--         return '<Tab>'
--     end
-- end, { expr = true, noremap = true })

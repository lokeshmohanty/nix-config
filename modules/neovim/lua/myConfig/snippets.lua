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
vim.keymap.set("i", "<Tab>", function() ms.expand() end)
-- vim.keymap.set("i", "<C-j>", function() ms.expand() end)
-- vim.keymap.set("i", "<C-l>", function() ms.session.jump("next") end)
-- vim.keymap.set("i", "<C-h>", function() ms.session.jump("prev") end)

-- [[ Completion ]]
require("blink.cmp").setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- See :h blink-cmp-config-keymap for configuring keymaps
  keymap = { preset = 'default' },
  appearance = {
    nerd_font_variant = 'mono'
  },
  signature = { enabled = true, window = { show_documentation = true, } },
  snippets = { preset = 'mini_snippets' },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = { org = { 'orgmode' } },
    providers = {
      path = { score_offset = 50, },
      lsp = { score_offset = 40, },
      snippets = { score_offset = 40, },
      orgmode = {
        name = 'Orgmode',
        module = 'orgmode.org.autocompletion.blink',
        fallbacks = { 'buffer' },
      },
    },
  },
})

-- [[ Snippets ]]
-- Examples: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets
local ms = require('mini.snippets')
local gen_loader = ms.gen_loader
ms.setup({
  snippets = {
    -- Load custom file with global snippets first
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

vim.keymap.set("i", "<C-g><C-j>", function() ms.expand({ match = false }) end)
-- vim.keymap.set("i", "<C-j>", function() ms.expand() end)
-- vim.keymap.set("i", "<C-l>", function() ms.session.jump("next") end)
-- vim.keymap.set("i", "<C-h>", function() ms.session.jump("prev") end)


-- [[ AI Completion ]]
-- Run :copilot auth
require("lze").load({{
  "copilot",
  ft = { "python" },
  keys = {
    { "<leader>ae", "<cmd>Copilot toggle<cr>", desc = "Toggle Copilot" },
    { "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
  },
  after = function (_)
    vim.cmd.packadd("copilot.lua")
    require("copilot").setup({})
    local cs = require("copilot.suggestion")
    vim.keymap.set("i", "<C-l>", cs.accept_line)
    vim.keymap.set("i", "<C-j>", cs.accept_word)

    vim.cmd.packadd("CopilotChat.nvim")
    require("CopilotChat").setup({})
  end,
}})

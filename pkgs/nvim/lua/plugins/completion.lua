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
    per_filetype = {
      codecompanion = { "codecompanion" },
    },
    providers = {
      path = { score_offset = 50, },
      lsp = { score_offset = 40, },
      snippets = { score_offset = 40, },
    },
  },
})

-- [[ Snippets ]]
-- Examples: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets
local ms = require('mini.snippets')
local gen_loader = ms.gen_loader
-- Adjust language patterns
local latex_patterns = { 'latex/**/*.lua', 'latex/**/*.json', '**/latex.json' }
local lang_patterns = {
  tex = latex_patterns, plaintex = latex_patterns,
  markdown_inline = { 'markdown.lua' },
  mdx = { 'markdown.lua' },
}
ms.setup({
  snippets = {
    -- Load custom file with global snippets first
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang({ lang_patterns = lang_patterns }),

  },
})

-- <Tab>: expand snippet if prefix matches → else native Tab (indent/spaces)
-- Uses 'n' feedkeys so the fallback cannot re-trigger this mapping.
local function tab_expand(match_fn)
  local session = ms.session.get()
  if session ~= nil then
    ms.session.jump('next')
    return
  end
  local matched = false
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prev_char = line:sub(col, col)

  if prev_char == "" or prev_char:match("%s") then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false
    )
    return
  end

  ms.expand({
    match = function(snippets)
      local m = (match_fn or ms.default_match)(snippets)
      matched = #m > 0
      return m
    end,
  })
  if not matched then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false
    )
  end
end

vim.keymap.set('i', '<Tab>', tab_expand)

-- Export so ft.lua can reuse the wrapper with a custom match function
_G.MiniSnippetsTabExpand = tab_expand

vim.keymap.set("i", "<C-j>", function() ms.expand() end)
vim.keymap.set("i", "<C-l>", function() ms.session.jump("next") end)
vim.keymap.set("i", "<C-h>", function() ms.session.jump("prev") end)


-- [[ AI Completion ]]
-- Run :copilot auth
-- require("copilot").setup({})
-- local cs = require("copilot.suggestion")
-- vim.keymap.set("i", "<C-l>", cs.accept_line)
-- vim.keymap.set("i", "<C-j>", cs.accept_word)
-- vim.keymap.set("n", "<leader>ac", "<cmd>Copilot toggle<cr>", { desc = "Toggle Copilot" })

require("claudecode").setup()
require("codecompanion").setup()

require('lze').load {{
  "claudecode.nvim",
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
  after = function(_)
    -- require("claudecode").setup()
    -- require("codecompanion").setup()
  end
}}

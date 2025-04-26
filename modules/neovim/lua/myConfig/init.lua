require("myConfig.keymap")
-- require('myConfig.lualine')
require("myConfig.lsp")
require("myConfig.markdown")
require("myConfig.latex")
require("myConfig.treesitter")
require("myConfig.snippets")
require("myConfig.fold")
require("myConfig.terminal")

-- vim.cmd([[ colorscheme retrobox ]])
require("everforest").load()

-- Completion
-- See: ins-completion
-- require('mini.completion').setup({
--   lsp_completion = {
--     source_func = 'omnifunc'
--   }
-- })

-- require('orgmode').setup({
--   org_agenda_files = '~/Documents/Org/*',
--   org_default_notes_file = '~/Documents/Org/tasks.org',
--   mappings = {
--     prefix = ',',
--     global = {
--       org_agenda = {'<leader>oa', desc = 'Org Agenda'},
--       org_capture = {'<leader>oc', desc = 'Org Capture'},
--     }
--   }
-- })

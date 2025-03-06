
require('myConfig.keymap')
require('myConfig.ipynb')
require('myConfig.python')
require('myConfig.lualine')



-- -- Create autocommand for markdown and ipynb files
-- vim.api.nvim_create_autocmd("BufEnter", {
--     pattern = { "*.md", "*.ipynb" },
--     callback = function()
--         vim.opt_local.wrap = false
--     end
-- })

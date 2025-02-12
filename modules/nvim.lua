vim.keymap.set('n', '<leader>mss', function()
    local input = vim.fn.input('Create session: ')
    vim.cmd('lua MiniSessions.write(input)')
    end, { noremap = true })

vim.keymap.set('n', '<leader>msd', function()
    local input = vim.fn.input('Delete session: ')
    vim.cmd('lua MiniSessions.write(input)')
    end, { noremap = true })

require('lualine').setup {
  options = {
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'filename', 'branch' },
    lualine_c = {
      '%=', --[[ add your center compoentnts here in place of this comment ]]
    },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}

-- Jupytext Configuration
require("jupytext").setup({
    style = "markdown",
    output_extension = "md",
    force_ft = "markdown",
})

-- Quarto Configuration
--
local quarto = require("quarto")
quarto.setup({
  lspFeatures = {
    languages = { "r", "python", "rust" },
    chunks = "all",
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  keymap = {
    -- NOTE: setup your own keymaps:
    hover = "H",
    definition = "gd",
    rename = "<leader>rn",
    references = "gr",
    format = "<leader>gf",
  },
  codeRunner = {
    enabled = true,
    default_method = "molten",
  },
})
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("quarto").activate()
  end,
})

-- Molten Configuration
vim.g.molten_auto_open_output = false
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_wrap_output = true
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true

vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten cell", silent = true })

-- if you work with html outputs:
vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })


-- Disable annoying pyright diagnostic
require("lspconfig")["pyright"].setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportUnusedExpression = "none",
                },
            },
        },
    },
})

-- Autocommands for Molten based on filetype
-- change the configuration when editing a python file
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function(e)
    if string.match(e.file, ".otter.") then
      return
    end
    if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
      vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
      vim.fn.MoltenUpdateOption("virt_text_output", false)
    else
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_virt_text_output = false
    end
  end,
})

-- Undo those config changes when we go back to a markdown or quarto file
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.qmd", "*.md", "*.ipynb" },
  callback = function(e)
    if string.match(e.file, ".otter.") then
      return
    end
    if require("molten.status").initialized() == "Molten" then
      vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
      vim.fn.MoltenUpdateOption("virt_text_output", true)
    else
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_output = true
    end
  end,
})

-- New Notebook
-- Provide a command to create a blank new Python notebook
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.
local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

vim.api.nvim_create_user_command('NewNotebook', function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = 'file'
})

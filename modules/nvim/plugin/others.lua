require('lze').load({
  {
    "gx",
    cmd = { "Browse" },
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } }, },
    before = function() vim.g.netrw_nogx = 1 end,
    after = function(_) 
      vim.cmd.packadd("gx")
      require("gx").setup({}) 
    end,
  },
  {
    "grug-far",
    cmd = { "GrugFar" },
    after = function(_) 
      vim.cmd.packadd("grug-far")
      require("grug-far").setup({}) 
    end,
  },
  {
    "typst-preview",
    -- Other commands: TypstPreview document / TypstPreview slide
    cmd = { 'TypstPreview', 'TypstPreviewToggle' },
    after = function(_)
      vim.cmd.packadd("typst-preview.nvim")
      require('typst-preview').setup({
        dependencies_bin = { ['tinymist'] = 'tinymist' }
      })
    end,
  },
  {
    "org-bullets",
    ft = "orgmode",
    after = function(_)
      vim.cmd.packadd("org-bullets")
      require("org-bullets").setup()
    end,
  },
  {
    "oil.nvim",
    keys = {
      {"<leader>-", "<cmd>Oil --float<CR>", desc = 'Open Parent Directory' },
    },
    after = function(_)
      vim.g.loaded_netrwPlugin = 1

      require("oil").setup({
        default_file_explorer = true,
        view_options = {
          show_hidden = true
        },
        columns = {
          "icon",
          "permissions",
          "size",
          -- "mtime",
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
      })
    end,
  },
  {
    "undotree",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
})

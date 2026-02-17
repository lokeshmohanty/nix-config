require('lze').load({
  {
    "gx",
    cmd = { "Browse" },
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } }, },
    before = function() vim.g.netrw_nogx = 1 end,
    after = function(_) 
      vim.cmd.packadd("gx.nvim")
      require("gx").setup({})
    end,
  }, {
    "grug-far",
    cmd = { "GrugFar" },
    after = function(_)
      vim.cmd.packadd("grug-far.nvim")
      require("grug-far").setup({})
    end,
  }, {
    "typst-preview",
    -- Other commands: TypstPreview document / TypstPreview slide
    cmd = { 'TypstPreview', 'TypstPreviewToggle' },
    after = function(_)
      vim.cmd.packadd("typst-preview.nvim")
      require('typst-preview').setup({
        dependencies_bin = { ['tinymist'] = 'tinymist' }
      })
    end,
  }, {
    "org-bullets",
    ft = "orgmode",
    after = function(_)
      vim.cmd.packadd("org-bullets")
      require("org-bullets").setup()
    end,
  }, {
    "flash.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    after = function(_)
      vim.packadd("flash.nvim")
      require("flash.nvim").setup()
    end,
  }, {
    "himalaya-ui",
    cmd = { "HimalayaUI" },
    keys = { { "<leader>H", "<cmd>HimalayaUI<CR>", mode = { "n" }, desc = "HimalayaUI" }, },
    after = function(_)
      vim.packadd("vim-himalaya-ui")
      require("himalaya-ui").setup({})
    end,
  }, {
    "undotree",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  }
})

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
    "markdown-preview",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
    after = function(_)
      vim.g.mkdp_auto_close = 0
      vim.cmd.packadd("markdown-preview")
      require("markdown-preview").setup({})
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
    "undotree",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
})

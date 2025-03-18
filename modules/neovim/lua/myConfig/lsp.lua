require("lspconfig").basedpyright.setup({
  settings = {
    basedpyright = {
      typeCheckingMode = 'off',
    },
  },
})
require("lspconfig").texlab.setup({
  settings = {
    texlab = {
      auxDiretory = ".",
      bibtexFormatter = "texlab",
      build = {
        executable = "tectonic",
        args = {
          "-X", "compile", "%f", "--synctex",
          "--keep-logs", "--keep-intermediates",
        },
        forwardSearchAfter = true,
        onSave = true,
      },
      chktex = {
        onEdit = false,
        onOpenAndSave = false,
      },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      -- forwardSearch = {
      --   executable = "zathura",
      --   args = {
      --     "--reuse-window",
      --     "--execute-command",
      --     "toggle_synctex",
      --     "--inverse-search",
      --     "texlab inverse-search -i \"%%1\" -l %%2",
      --     "--forward-search-file",
      --     "%f",
      --     "--forward-search-line",
      --     "%l",
      --     "%p",
      --   },
      -- },
      latexForamtter = "latexindent",
      latexindent = {
        modifyLineBreaks = false
      }
    }
  }
})

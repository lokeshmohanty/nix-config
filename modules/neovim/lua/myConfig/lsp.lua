require("nvim-treesitter.configs").setup({
			ensure_installed = { "nix", "lua", "vim", "vimdoc", "markdown", "markdown_inline" },
			auto_install = true,
			parser_install_dir = "/home/lokesh/.config/nvf/parsers/",
})
require("lspconfig").basedpyright.setup({
  settings = {
    basedpyright = {
      typeCheckingMode = 'off',
    },
  },
})
require("lspconfig").ts_ls.setup({})
require("lspconfig").texlab.setup({})
-- require("tailwind-tools").setup({})
-- require("lspconfig").lua_ls.setup({
--   settings = {
--     Lua = {
--       diagnostics = {
--         disable = { "missing-fields", "incomplete-signature-doc" },
--       },
--     },
--   },
-- })
-- require("lspconfig").texlab.setup({
--   settings = {
--     texlab = {
--       auxDiretory = ".",
--       bibtexFormatter = "texlab",
--       build = {
--         executable = "tectonic",
--         args = {
--           "-X", "compile", "%f", "--synctex",
--           "--keep-logs", "--keep-intermediates",
--         },
--         forwardSearchAfter = true,
--         onSave = true,
--       },
--       chktex = {
--         onEdit = false,
--         onOpenAndSave = false,
--       },
--       diagnosticsDelay = 300,
--       formatterLineLength = 80,
--       -- forwardSearch = {
--       --   executable = "zathura",
--       --   args = {
--       --     "--synctex-forward",
--       --     "texlab inverse-search -i \"%%1\" -l %%2",
--       --     "--forward-search-file",
--       --     "%f",
--       --     "--forward-search-line",
--       --     "%l",
--       --     "%p",
--       --   },
--       -- },
--       latexForamtter = "latexindent",
--       latexindent = {
--         modifyLineBreaks = false
--       }
--     }
--   }
-- })

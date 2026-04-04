require("plugins.debug")
require("plugins.format")
require("plugins.lsp")
require("plugins.completion") -- Completion (blink, snippets, copilot)
require("plugins.general_ui")
require("plugins.gitsigns")
require("plugins.lint")
require("plugins.noice")

require("plugins.mini")
require("plugins.snacks")

require("lze").load(require("plugins.optional"))
require("lze").load({
  { import = "plugins.zk" },
  { import = "plugins.notmuch" },
  -- {
  --   "vim-table-mode",
  --   ft = "markdown",
  --   after = function(_)
  --     vim.cmd.packadd("vim-table-mode")
  --   end,
  -- },
})


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
require("plugins.optional")         -- lazy-loaded plugins

require("lze").load({
  { import = "plugins.zk" },
})


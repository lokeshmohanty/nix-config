vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    vim.opt.wrap = false
  end
})

-- local presets = require("markview.presets");
require("markview").setup({
  hyprid_modes = { "n" },
  code_blocks = { icons = "mini" },
  -- markdown = {
  --   headings = presets.headings.arrowed,
  --   horizontal_rules = presets.horizontal_rules.thin,
  --   -- tables = presets.table.none
  -- },
});

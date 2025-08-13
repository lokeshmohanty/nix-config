vim.cmd.colorscheme(nixCats('colorscheme'))

local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  vim.keymap.set("n", "<Esc>", function()
      notify.dismiss({ silent = true, })
  end, { desc = "dismiss notify popup and clear hlsearch" })
end

if nixCats('general.extra') then
  require("myConfig.plugins.snacks")
  require("myConfig.plugins.snippet")
  require("myConfig.plugins.session")
  require("myConfig.plugins.file-manager")
  require("myConfig.plugins.fold")

  require("mini.pairs").setup({})
  require("mini.starter").setup({})
  -- require("mini.tabline").setup({})
  -- require("mini.icons").setup()
end


if nixCats('tex') then
  -- vim.g.vimtex_view_method = 'zathura'

  vim.g.vimtex_view_general_viewer = 'okular'
  vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'
end

if nixCats('orgmode') then
  require("orgmode").setup({
    org_agenda_files = "~/Documents/Org/*",
    org_default_notes_file = "~/Documents/Org/notes.org",
  })
  require("org-roam").setup({
    directory = "~/Documents/Org/Roam",
  })
  require("org-bullets").setup()
end

require('myConfig.plugins.debug')
require('lze').load {
  { import = "myConfig.plugins.lint", },
  { import = "myConfig.plugins.format", },
  { import = "myConfig.plugins.telescope", },
  { import = "myConfig.plugins.treesitter", },
  { import = "myConfig.plugins.completion", },
  { import = "myConfig.plugins.which-key", },
  { import = "myConfig.plugins.gitsigns", },
  { import = "myConfig.plugins.ai", },
  {
    "typst-preview.vim",
    for_cat = 'typst',
    cmd = { 'TypstPreview', 'TypstPreviewToggle' },
    after = function(plugin)
      require('typst-preview').setup({ 
        dependencies_bin = { ['tinymist'] = 'tinymist' }
      })
    end,
  },
  {
    "markdown-preview.nvim",
    for_cat = 'general.markdown',
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
    ft = "markdown",
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "undotree",
    for_cat = 'general.extra',
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "comment.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    "indent-blankline.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
  {
    "nvim-surround",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    "vim-startuptime",
    for_cat = 'general.extra',
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "fidget.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('fidget').setup({})
    end,
  },
  {
    "lualine.nvim",
    for_cat = 'general.always',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)

      require('lualine').setup({
        options = {
          icons_enabled = false,
          theme = colorschemeName,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename', path = 1, status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename', path = 3, status = true,
            },
          },
          lualine_x = {'filetype'},
        },
        tabline = {
          lualine_a = { 'buffers' },
          -- if you use lualine-lsp-progress, I have mine here instead of fidget
          -- lualine_b = { 'lsp_progress', },
          lualine_z = { 'tabs' }
        },
      })
    end,
  },
}

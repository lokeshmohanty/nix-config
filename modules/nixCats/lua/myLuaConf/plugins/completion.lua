local load_w_after = function(name)
  vim.cmd.packadd(name)
  vim.cmd.packadd(name .. '/after')
end

return {
  {
    "cmp-cmdline",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
    load = load_w_after,
  },
  {
    "blink.compat",
    for_cat = "general.blink",
    dep_of = { "cmp-cmdline" },
  },
  {
    "colorful-menu.nvim",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
  },
  {
    "blink.cmp",
    for_cat = "general.blink",
    event = "DeferredUIEnter",
    after = function (_)
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        snippets = {
          preset = 'mini_snippets',
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', 'omni' },
          per_filetype = { org = {'orgmode'} },
          providers = {
            path = { score_offset = 50, },
            lsp = { score_offset = 40, },
            snippets = { score_offset = 40, },
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
            orgmode = {
              name = 'Orgmode',
              module = 'orgmode.org.autocompletion.blink',
              fallbacks = { 'buffer' },
            },
          },
        },
      })
    end,
  },
}

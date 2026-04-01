-- NOTE: lsp setup via lspconfig

local servers = {}

-- most don't need much configuration
-- servers.gopls = {}
servers.clangd = {}
servers.bashls = {}
servers.zuban = {} -- python
servers.tinymist = {}
servers.rust_analyzer = {}
servers.hls = { filetypes = { 'haskell', 'lhaskell', 'cabal' }, }
servers.texlab = {}
servers.ts_ls = {}
servers.yamlls = {}
servers.hydra_lsp = {}
servers.tailwindcss = {}
servers.zk = {}
servers.nushell = {}
servers.nginx_language_server = {}
servers.gh_actions_ls = {}

-- but you can provide some if you want to!
servers.lua_ls = {
  settings = {
    Lua = {
      formatters = {
        ignoreComments = false,
      },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { 'vim' },
        disable = { 'missing-fields' },
      },
    }
  }
}
-- nixd requires some configuration.
-- for additional configuration options, refer to:
-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
servers.nixd = {
  settings = {
    nixd = {
      nixpkgs = {
        expr = [[import <nixpkgs> {}]],
      },
      formatting = {
        command = { "nixfmt" }
      },
      diagnostic = {
        suppress = {
          "sema-escaping-with"
        }
      }
    }
  }
}

vim.lsp.config('*', {
  -- capabilities = capabilities,
  on_attach = function(_, bufnr)
    -- we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
    nmap('<leader>cwa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>cwr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>cwl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})

-- set up the servers to be loaded on the appropriate filetypes!
for server_name, cfg in pairs(servers) do
  vim.lsp.config(server_name, cfg)
  vim.lsp.enable(server_name)
end

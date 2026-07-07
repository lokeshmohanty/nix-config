-- VimTeX configuration

-- Use sioyek for PDF viewing
vim.g.vimtex_view_method = 'sioyek'

-- latexmk with LuaLaTeX, continuous mode, SyncTeX
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
  build_dir = '',
  callback = 1,
  continuous = 1,
  executable = 'latexmk',
  hooks = {},
  options = {
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
    '-shell-escape',
    '-lualatex',
  },
}

-- Disable vimtex's insert mode mappings — mini.snippets handles those
vim.g.vimtex_imaps_enabled = 0

-- Conceal: show α instead of \alpha, ⊆ instead of \subseteq, etc.
vim.g.vimtex_syntax_conceal = {
  accents = 1,
  cites = 1,
  fancy = 1,
  greek = 1,
  math_bounds = 1,
  math_delimiters = 1,
  math_fracs = 1,
  math_super_sub = 1,
  math_symbols = 1,
  sections = 0,
  styles = 1,
}

-- texlab LSP additional config (server already enabled in lsp.lua)
vim.lsp.config('texlab', {
  settings = {
    texlab = {
      build = {
        executable = 'latexmk',
        args = { '-lualatex', '-interaction=nonstopmode', '-synctex=1', '-shell-escape', '%f' },
        onSave = false,
        forwardSearchAfter = false,
      },
      chktex = { onOpenAndSave = true },
      forwardSearch = {
        executable = 'sioyek',
        args = {
          '--reuse-window',
          '--execute-command', 'turn_on_synctex',
          '--input-file', '%p',
          '--forward-search-file', '%f',
          '--forward-search-line', '%l',
        },
      },
    },
  },
})

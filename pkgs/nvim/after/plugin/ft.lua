--------------------------------
------------- Lua --------------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		vim.cmd.packadd('lazydev.nvim')
		require('lazydev').setup({})
	end,
})

--------------------------------
------------- Typst ------------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typst" },
	callback = function()
		vim.keymap.set("n", "<localleader>p", "<cmd>TypstPreviewToggle<CR>", { desc = "preview" })
	end,
})

--------------------------------
------------- Tex --------------
--------------------------------
local function in_mathzone()
  if vim.fn.exists('*vimtex#syntax#in_mathzone') == 1 then
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
  end
  return false
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex" },
  callback = function()
    -- Conceal: show α instead of \alpha
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'nc'

    -- Math-context-aware match: filters snippets by condition = 'math'/'text'
    local function math_match(snippets)
      local in_math = in_mathzone()
      local available = vim.tbl_filter(function(s)
        local cond = s.condition
        if cond == 'math' then return in_math end
        if cond == 'text' then return not in_math end
        return true
      end, snippets)
      return require('mini.snippets').default_match(available)
    end

    -- <Tab>: math-aware expand → fallback to native Tab
    vim.keymap.set('i', '<Tab>', function()
      _G.MiniSnippetsTabExpand(math_match)
    end, { buffer = true })

    -- <C-j>: same but always-expand (no fallback needed here)
    vim.keymap.set("i", "<C-j>", function()
      require('mini.snippets').expand({ match = math_match })
    end, { buffer = true })

    -- Inkscape figure workflow:
    --   new figure → create SVG template + insert \includegraphics block + open Inkscape
    --   existing figure → just open Inkscape for re-editing
    --   on Inkscape close → auto-export SVG → PDF (latexmk picks it up)
    local function inkscape_figure()
      vim.ui.input({ prompt = 'Figure name: ' }, function(name)
        if not name or name == '' then return end

        local tex_dir = vim.fn.expand('%:p:h')
        local fig_dir = tex_dir .. '/figures'
        local svg_path = fig_dir .. '/' .. name .. '.svg'
        local pdf_path = fig_dir .. '/' .. name .. '.pdf'

        vim.fn.mkdir(fig_dir, 'p')

        if vim.fn.filereadable(svg_path) == 0 then
          -- Minimal A4-width SVG template
          local f = io.open(svg_path, 'w')
          if f then
            f:write(table.concat({
              '<?xml version="1.0" encoding="UTF-8"?>',
              '<svg xmlns="http://www.w3.org/2000/svg"',
              '     width="160mm" height="100mm"',
              '     viewBox="0 0 160 100" version="1.1">',
              '</svg>',
            }, '\n'))
            f:close()
          end

          -- Insert figure environment below the current line
          local row = vim.api.nvim_win_get_cursor(0)[1]
          local caption = name:gsub('[_-]', ' ')
          vim.api.nvim_buf_set_lines(0, row, row, false, {
            '\\begin{figure}[htbp]',
            '  \\centering',
            '  \\includegraphics[width=\\textwidth]{figures/' .. name .. '}',
            '  \\caption{' .. caption .. '}',
            '  \\label{fig:' .. name .. '}',
            '\\end{figure}',
          })
          -- Land cursor on caption text
          vim.api.nvim_win_set_cursor(0, { row + 4, 12 })
        end

        -- Open Inkscape; export SVG → PDF when it closes
        vim.fn.jobstart({ 'inkscape', svg_path }, {
          on_exit = function(_, code)
            if code ~= 0 then return end
            vim.fn.jobstart({ 'inkscape', '--export-filename=' .. pdf_path, svg_path }, {
              on_exit = function(_, ec)
                if ec == 0 then
                  vim.schedule(function()
                    vim.notify('figures/' .. name .. '.pdf exported', vim.log.levels.INFO)
                  end)
                end
              end,
            })
          end,
        })
      end)
    end

    -- VimTeX keymaps under <localleader>l
    local nmap = function(k, v, d) vim.keymap.set('n', k, v, { buffer = true, desc = d }) end
    nmap('<localleader>ll', '<cmd>VimtexCompile<cr>',      'Compile (toggle)')
    nmap('<localleader>lv', '<cmd>VimtexView<cr>',         'View PDF')
    nmap('<localleader>lc', '<cmd>VimtexClean<cr>',        'Clean aux files')
    nmap('<localleader>le', '<cmd>VimtexErrors<cr>',       'Show errors')
    nmap('<localleader>lt', '<cmd>VimtexTocToggle<cr>',    'Toggle TOC')
    nmap('<localleader>li', '<cmd>VimtexInfo<cr>',         'VimTeX info')
    nmap('<localleader>ls', '<cmd>VimtexStop<cr>',         'Stop compiler')
    nmap('<localleader>lF', inkscape_figure,               'Insert/edit figure (Inkscape)')
  end,
})

-- SVG → PDF auto-export (inkscape); latexmk picks up the new PDF automatically
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.svg',
  callback = function(ev)
    local svg = vim.fn.expand('<afile>:p')
    local pdf = svg:gsub('%.svg$', '.pdf')
    vim.fn.jobstart(
      { 'inkscape', '--export-filename=' .. pdf, svg },
      {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify('SVG exported: ' .. vim.fn.fnamemodify(pdf, ':t'), vim.log.levels.INFO)
          else
            vim.notify('inkscape export failed (code ' .. code .. ')', vim.log.levels.WARN)
          end
        end,
      }
    )
  end,
})

--------------------------------
------------- Markdown ---------
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function()
		if require("zk.util").notebook_root(vim.fn.expand('%:p')) ~= nil then
			local function map(...) vim.api.nvim_buf_set_keymap(0, ...) end
			local opts = { noremap=true, silent=false }
			map("n", "K",           "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			map("n", "<CR>",        "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

			map("n", "<leader>zn",  "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
			map("n", "<leader>zl",  "<Cmd>ZkLinks<CR>", opts)
			map("n", "<leader>zb",  "<Cmd>ZkBacklinks<CR>", opts)
			--map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)

			map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
			map("v", "<leader>znc", ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
			map("v", "<leader>zi",  ":'<,'>ZkInsertLinkAtSelection { title = vim.fn.input('Title: ') }<CR>", opts)
			map("v", "<leader>za",  ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
		end
	end,
})


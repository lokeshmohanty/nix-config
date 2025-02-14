{ pkgs, ... }: {
  
  vim = {
    searchCase = "smart";
    useSystemClipboard = true;
    enableLuaLoader = true;
    additionalRuntimePaths = [ ./nvim ];
    luaConfigPost = "${builtins.readFile ./nvim/lua/main.lua}";
    options = { 
      tabstop = 2; 
      shiftwidth = 0; 
      expandtab = true;
    };
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
    keymaps = [
      { key = "<leader><leader>i"; mode = "n"; 
        action = "<cmd>IconPickerYank<cr>"; }
      { key = "<leader><leader>p"; mode = "n"; 
        action = "<cmd>MarkdownPreviewToggle<cr>"; }
      { key = "<leader>sd"; mode = "n";
        action = "<cmd>lua MiniFiles.open()<cr>"; }
      { key = "<leader>sf"; mode = "n";
        action = "<cmd>Pick files<cr>"; }
      { key = "<leader>sb"; mode = "n";
        action = "<cmd>Pick buffers<cr>"; }
      { key = "<leader>ss"; mode = "n";
        action = "<cmd>Pick grep_live<cr>"; }
      { key = "<leader>sm"; mode = "n";
        action = "<cmd>Neogit<cr>"; }
    ];
    spellcheck.enable = false;
    spellcheck.programmingWordlist.enable = true;
    statusline.lualine = {
      enable = true;
    };
    autocomplete.nvim-cmp = {
      enable = true;
      mappings.next = "<C-n>";
      mappings.previous = "<C-p>";
      # sourcePlugins = with pkgs.vimPlugins; [ lazydev-nvim ];
    };

    binds.whichKey.enable = true;
    telescope.enable = true;
    

    snippets.luasnip = {
      enable = true;
      loaders = ''
        require("luasnip.loaders.from_snipmate").lazy_load()
        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvf/snippets" })
      '';
      providers = with pkgs.vimPlugins; [ vim-snippets ];
    };
    treesitter.context.enable = true;

    debugger.nvim-dap.enable = true;
    debugger.nvim-dap.ui.enable = true;
    lsp.enable = true;
    languages = {
      enableLSP = true;
      enableDAP = true;
      enableFormat = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;

      nix.enable = true;
      clang.enable = true;
      python.enable = true;
      haskell.enable = true;
      # rust.enable = true;
      markdown.enable = true;
      html.enable = true;
      lua.enable = true;
    };
    # notify.nvim-notify.enable = true;
    notes.orgmode.enable = true;

    mini = {
      icons.enable = true;
      files.enable = true;
      basics.enable = true;
      # surround.enable = true;
      pairs.enable = true;
      comment.enable = true;
      bracketed.enable = true;
      move.enable = true;
      jump2d.enable = true;
      notify.enable = true;
      pick.enable = true;
      sessions.enable = true;
      sessions.setupOpts = { 
        directory = "~/.config/nvf/sessions"; 
      };
      starter.enable = true;
    };
    utility = {
      # ccc.enable = true;
      icon-picker.enable = true;
      # diffview-nvim.enable = true;
      images.image-nvim.enable = true;
      images.image-nvim.setupOpts = {
        integrations.markdown.downloadRemoteImages = true;
      };
      surround.enable = true;
      surround.useVendoredKeybindings = false;
      outline.aerial-nvim.enable = true;
      preview.markdownPreview.enable = true;
    };
    assistant.copilot = {
      enable = true;
      mappings = {
        suggestion = {
          accept = "<C-Enter>";
          acceptLine = "<C-l>";
          next = "<M-]>";
          prev = "<M-[>";
        };
      };
    };

    ui = {
      borders.enable = false;
      noice.enable = false;
      colorizer.enable = true;
      fastaction.enable = true;
    };

    lazy.plugins = {
      vimtex = {
        enabled = true;
        package = pkgs.vimPlugins.vimtex;
        lazy = true;
        ft = "tex";
        setupOpts = {
          init = ''
            vim.g.vimtex_view_general_viewer = "okular"
            vim.g.vimtex_view_general_options = "--unique file:@pdf\#src:@line@tex"
          '';
        };
        after =  ''
          vim.api.nvim_command('unlet b:did_ftplugin')
          vim.api.nvim_command('call vimtex#init()')
        '';
      };
    };
    extraPlugins = with pkgs.vimPlugins; {
      neogit.package = neogit;
      jupytext = {
        package = jupytext-nvim;
        setup = "require('jupytext').setup({})";
      };
      quarto.package = quarto-nvim;
      molten = {
        package = molten-nvim;
        setup = ''
          vim.g.molten_image_provider = "image.nvim"
        '';
      };
    };
    withPython3 = true; withNodeJs = true;
    extraPackages = with pkgs; [ 
      ripgrep 
      imagemagick 
      neovim-remote
    ];
    luaPackages = [ "magick" ];
    python3Packages = [
      "pynvim" 
      "jupyter-client" 
      "nbformat"
      "cairosvg" 
      "pnglatex"
      "plotly" 
      "pyperclip" 
    ];
  };
}

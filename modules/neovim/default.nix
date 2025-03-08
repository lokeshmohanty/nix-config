{ pkgs, ... }: {
  
  vim = {
    searchCase = "smart";
    useSystemClipboard = true;
    enableLuaLoader = true;
    withPython3 = true; 
    withNodeJs = true;
    additionalRuntimePaths = [ ./. ];
    luaConfigRC.myConfig = ''
      require("myConfig")
    '';
    options = { 
      tabstop = 2; 
      shiftwidth = 0; 
      expandtab = true;
    };
    theme = {
      enable = true;
      name = "mini-base16";
      base16-colors = { # style: terracotta
        base00 = "#efeae8";
        base01 = "#dfd6d1";
        base02 = "#d0c1bb";
        base03 = "#c0aca4";
        base04 = "#59453d";
        base05 = "#473731";
        base06 = "#352a25";
        base07 = "#241c19";
        base08 = "#a75045";
        base09 = "#bd6942";
        base0A = "#ce943e";
        base0B = "#7a894a";
        base0C = "#847f9e";
        base0D = "#625574";
        base0E = "#8d5968";
        base0F = "#b07158";
      };
    };
    spellcheck.enable = false;
    spellcheck.programmingWordlist.enable = true;
    statusline.lualine = {
      enable = true;
    };
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
        keymap.preset = "super-tab";
        snippets.preset = "luasnip";
        sources.providers = {
          lazydev = {
            name = "LazyDev";
            module = "lazydev.integrations.blink";
          };
        };
        sources.default = [ "lazydev" ];
      };
      mappings = {
        confirm = "<TAB>";
        next = "<C-n>";
        previous = "<C-p>";
      };
    };
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
      enableExtraDiagnostics = false;
      enableTreesitter = true;

      nix.enable = true;
      clang.enable = true;
      python.enable = true;
      haskell.enable = true;
      markdown.enable = true;
      typst.enable = true;
      html.enable = true;
      lua.enable = true;
    };
    notes.orgmode.enable = true;
    binds.whichKey.enable = true;
    mini = {
      icons.enable = true;
      files.enable = true;
      basics.enable = true;
      pairs.enable = true;
      comment.enable = true;
      notify.enable = true;
      bracketed.enable = true;
      sessions.enable = true;
      sessions.setupOpts = { 
        directory = "~/.config/nvf/sessions"; 
      };
      starter.enable = true;
      tabline.enable = true;
    };
    fzf-lua.enable = true;
    # notify.nvim-notify.enable = true;
    utility = {
      ccc.enable = true;
      icon-picker.enable = true;       # :IconPicker
      diffview-nvim.enable = true;     # :Diffview
      # images.image-nvim.enable = true;
      # images.image-nvim.setupOpts = {
      #   maxWidth = 60;
      #   maxHeight = 12;
      #   integrations.markdown = {
      #     downloadRemoteImages = true;
      #     onlyRenderAtCursor = true;
      #   };
      # };
      surround.enable = true;
      surround.useVendoredKeybindings = false;
      outline.aerial-nvim.enable = true;
      preview.markdownPreview.enable = true;
    };
    ui = {
      borders.enable = false;
      noice.enable = true;
      colorizer.enable = true;
      fastaction.enable = true;
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
    startPlugins = with pkgs.vimPlugins; [
      render-markdown-nvim
      neogit                # magit alternative for vim
      jupytext-nvim         # convert ipynb to markdown
      quarto-nvim           # empowered markdown
      molten-nvim           # run ipynb from vim
      everforest            # green based colorscheme
      bullets-vim           # markdown insert bulleted lists ...
      img-clip-nvim         # drag n drop images
      vim-floaterm
      yazi-nvim
    ];
    extraPlugins = with pkgs.vimPlugins; {
      lazydev = {  # neovim library for lua lsp
        package = lazydev-nvim;
        setup = "require('lazydev').setup {}";
      };
    };
    extraPackages = with pkgs; [ 
      ripgrep 
      imagemagick 
      ueberzugpp
      basedpyright
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

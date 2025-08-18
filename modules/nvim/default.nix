{ pkgs, utils , ... }: let
  # path to your new .config/nvim
  luaPath = ./.;

  # see :help nixCats.flake.outputs.categories
  categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        lua-language-server
        stylua

        nixd
        alejandra

        python3Packages.python-lsp-server
        # texlab
        tinymist
      ];
    };

    # This is for plugins that will load at startup without using packadd:
    startupPlugins = {
      general = with pkgs.vimPlugins; [
        lze
        vim-sleuth

        snacks-nvim
        mini-nvim
        # mini-ai
        # mini-icons
        # mini-pairs
        fzf-lua
        oil-nvim
        neogit
        nvim-surround

        nvim-lspconfig
        blink-cmp
        # nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars

        lualine-nvim
        lualine-lsp-progress
        gitsigns-nvim
        which-key-nvim
        render-markdown-nvim

        vimtex

        # orgmode
        orgmode
        org-roam-nvim
        sniprun
        pkgs.neovimPlugins.org-bullets

        nvim-lint
        conform-nvim
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        # nvim-dap-view
        # nvim-nio

        pkgs.neovimPlugins.everforest
      ];
    };

    # not loaded automatically at startup.
    # use with packadd and an autocommand in config to achieve lazy loading
    optionalPlugins = {
      general = with pkgs.vimPlugins; [
        lazydev-nvim
        vim-startuptime
        typst-preview-nvim
        copilot-lua
        CopilotChat-nvim
        markdown-preview-nvim
        nvim-dap-python

        grug-far-nvim
        gx-nvim

        undotree
      ];
    };
  };

  # see :help nixCats.flake.outputs.packageDefinitions
  packageDefinitions = rec {
    nvim = {pkgs, name, mkPlugin, ... }: {
      settings = {
        suffix-path = true;
        suffix-LD = true;
        aliases = [ "vi" ];
        configDirName = "nvim";
        hosts.python3.enable = false;
        hosts.node.enable = false;
        hosts.ruby.enable = false;
        hosts.perl.enable = false;
      };
      categories = { general = true; };
      extra = {};
    };
    vi = nvim // { settings.wrapRC = false; };
  };

  # We will build the one named nvim here and export that one.
  defaultPackageName = "nvim";

# return our package!
in utils.baseBuilder luaPath { inherit pkgs; } categoryDefinitions packageDefinitions defaultPackageName
# NOTE: or to return a set of all of them:
# `in utils.mkAllPackages (utils.baseBuilder luaPath { inherit pkgs; } categoryDefinitions packageDefinitions defaultPackageName)`

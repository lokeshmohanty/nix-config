{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  utils = inputs.nixCats.utils;
  pluginOverlay = utils.standardPluginOverlay inputs;
  nvimPkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ pluginOverlay ];
  };

  # path to your new .config/nvim
  luaPath = ./.;

  # see :help nixCats.flake.outputs.categories
  categoryDefinitions =
    {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    }@packageDef:
    {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          lua-language-server
          stylua # lua
          nixd
          nixfmt # nix
          zuban # python
          tinymist # typst
          rust-analyzer
          rustfmt # rust

          # haskell
          haskell-language-server
          haskellPackages.cabal-fmt
          ormolu

          yaml-language-server
          typescript-language-server
          tailwindcss-language-server
          nginx-language-server
          bash-language-server

          tree-sitter # for treesitter
          trashy # for Snacks.Explorer
          mermaid-cli
          imagemagick # for Snacks.Image
          ghostscript # for Snacks.Image
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        general = with pkgs.vimPlugins; [
          lze # lazy-load plugins
          vim-sleuth # heuristically set buffer options
          vim-slime # send text to live repl
          Recover-vim # add compare action for swap files
          plenary-nvim # for async lua

          snacks-nvim
          mini-nvim
          neogit
          noice-nvim

          nvim-lspconfig
          blink-cmp
          nvim-treesitter.withAllGrammars

          # lualine-nvim
          # lualine-lsp-progress
          pkgs.neovimPlugins.slimline
          gitsigns-nvim
          which-key-nvim
          render-markdown-nvim
          markdown-preview-nvim
          img-clip-nvim
          copilot-lua
          codecompanion-nvim
          claudecode-nvim

          vimtex

          zk-nvim

          nvim-lint
          conform-nvim
          nvim-dap
          nvim-dap-view
          nvim-dap-virtual-text
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

          nvim-dap-python

          grug-far-nvim
          gx-nvim
          flash-nvim # jump

          undotree
          pkgs.neovimPlugins.himalaya-ui
        ];
      };
    };

  # see :help nixCats.flake.outputs.packageDefinitions
  packageDefinitions = rec {
    nvim =
      {
        pkgs,
        name,
        mkPlugin,
        ...
      }:
      {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          aliases = [ "vi" ];
          configDirName = "nvim";
          hosts.python3.enable = true;
          hosts.node.enable = true;
          hosts.ruby.enable = false;
          hosts.perl.enable = false;
        };
        categories = {
          general = true;
        };
        extra = { };
      };
    vi = nvim // {
      settings.wrapRC = false;
    };
  };

  # We will build the one named nvim here and export that one.
  defaultPackageName = "nvim";
  # return our package!
in
utils.baseBuilder luaPath {
  pkgs = nvimPkgs;
} categoryDefinitions packageDefinitions defaultPackageName
# NOTE: or to return a set of all of them:
# `in utils.mkAllPackages (utils.baseBuilder luaPath { inherit pkgs; } categoryDefinitions packageDefinitions defaultPackageName)`

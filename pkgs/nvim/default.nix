{ pkgs, inputs, ... }:
let
  customPlugins = {
    slimline = pkgs.vimUtils.buildVimPlugin {
      pname = "slimline.nvim";
      version = "source";
      src = inputs.plugins-slimline;
      doCheck = false; # as slimline doesn't work at compile time
    };
    everforest = pkgs.vimUtils.buildVimPlugin {
      pname = "everforest-nvim";
      version = "source";
      src = inputs.plugins-everforest;
    };
    notmuch-nvim = pkgs.vimUtils.buildVimPlugin {
      pname = "notmuch-nvim";
      version = "source";
      src = ./lua/notmuch.nvim;
      doCheck = false;
    };
    bruno = pkgs.vimUtils.buildVimPlugin {
      pname = "bruno";
      version = "source";
      src = inputs.plugins-bruno;
      doCheck = false;
    };
  };
in
inputs.nix-wrapper-modules.wrappers.neovim.wrap [
  { inherit pkgs; }
  (
    { pkgs, ... }:
    {
      settings = {
        config_directory = "/home/lokesh/.config/nvim";
        aliases = [ "vi" ];
      };

      hosts.python3.nvim-host.enable = true;
      hosts.node.nvim-host.enable = true;
      hosts.ruby.nvim-host.enable = false;
      hosts.perl.nvim-host.enable = false;

      extraPackages = with pkgs; [
        lua-language-server
        stylua
        nixd
        nixfmt
        zuban
        tinymist
        rust-analyzer
        rustfmt
        haskell-language-server
        haskellPackages.cabal-fmt
        ormolu
        yaml-language-server
        typescript-language-server
        tailwindcss-language-server
        nginx-language-server
        bash-language-server
        helm-ls
        terraform-ls
        tree-sitter
        trashy
        mermaid-cli
        imagemagick
        ghostscript
        w3m-full # required for notmuch
        notmuch # required for notmuch
        bruno-cli # required for bruno
        texlab # LaTeX
      ];

      specs.general = {
        data = with pkgs.vimPlugins; [
          lze
          vim-sleuth
          vim-slime
          Recover-vim
          plenary-nvim
          snacks-nvim
          mini-nvim
          neogit
          noice-nvim
          nvim-lspconfig
          blink-cmp
          nvim-treesitter.withAllGrammars
          customPlugins.slimline
          gitsigns-nvim
          which-key-nvim
          render-markdown-nvim
          markdown-preview-nvim
          img-clip-nvim
          copilot-lua
          codecompanion-nvim
          claudecode-nvim
          vimtex
          nvim-lint
          conform-nvim
          nvim-dap
          nvim-dap-view
          nvim-dap-virtual-text
          customPlugins.everforest

          helm-ls-nvim
        ];
      };

      specs.optional = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          lazydev-nvim
          vim-startuptime
          typst-preview-nvim
          zk-nvim
          nvim-dap-python
          grug-far-nvim
          gx-nvim
          flash-nvim
          undotree
          # customPlugins.notmuch-nvim
          customPlugins.bruno
        ];
      };
    }
  )
]

{
  description = "My neovim flake using nixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-org-bullets" = {
      url = "github:nvim-orgmode/org-bullets.nvim";
      flake = false;
    };
    "plugins-everforest" = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    # forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    pluginOverlay = utils.standardPluginOverlay inputs;
  in
  {
    packages = forEachSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [pluginOverlay]; config = {}; };
    in utils.mkAllWithDefault (import ./. (inputs // { inherit pkgs utils; })));
    homeModule = self.packages.x86_64-linux.default.homeModule;
    nixosModule = self.packages.x86_64-linux.default.nixosModule;
  };

  # outputs1 = {
  #   self,
  #   nixpkgs,
  #   ...
  # } @ inputs: let
  #   inherit (inputs.nixCats) utils;
  #   luaPath = ./.;
  #   forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
  #   extra_pkg_config = { allowUnfree = true; };
  #   dependencyOverlays =
  #     /*
  #     (import ./overlays inputs) ++
  #     */
  #     [
  #       # This overlay grabs all the inputs named in the format
  #       # `plugins-<pluginName>`
  #       # Once we add this overlay to our nixpkgs, we are able to
  #       # use `pkgs.neovimPlugins`, which is a set of our plugins.
  #       (utils.standardPluginOverlay inputs)
  #
  #       # when other people mess up their overlays by wrapping them with system,
  #       # you may instead call this function on their overlay.
  #       # it will check if it has the system in the set, and if so return the desired overlay
  #       # (utils.fixSystemizedOverlay inputs.codeium.overlays
  #       #   (system: inputs.codeium.overlays.${system}.default)
  #       # )
  #     ];
  #
  #   categoryDefinitions = {
  #     pkgs,
  #     settings,
  #     categories,
  #     extra,
  #     name,
  #     mkPlugin,
  #     ...
  #   } @ packageDef: {
  #     lspsAndRuntimeDeps = {
  #       general = with pkgs; [
  #         universal-ctags
  #         ripgrep
  #         fd
  #         mermaid-cli
  #         ghostscript
  #       ];
  #       python = with pkgs; [python3Packages.python-lsp-server];
  #       elixir = with pkgs; [beam28Packages.elixir-ls];
  #       tex = with pkgs; [texlab];
  #       typst = with pkgs; [tinymist];
  #       go = with pkgs; [
  #         gopls
  #         gotools
  #         go-tools
  #         gccgo
  #         delve # debug
  #       ];
  #       lua = with pkgs; [lua-language-server stylua];
  #       nix = {inherit (pkgs) nix-doc nixd alejandra;};
  #     };
  #
  #     # This is for plugins that will load at startup without using packadd:
  #     startupPlugins = {
  #       general = with pkgs.vimPlugins; [
  #         ## always
  #         lze
  #         vim-repeat
  #         plenary-nvim
  #         nvim-notify
  #
  #         ## dev
  #         nvim-dap-go
  #         nvim-dap-python
  #         nvim-nio # debug
  #         nvim-dap
  #         nvim-dap-ui
  #         # nvim-dap-view
  #         nvim-dap-virtual-text
  #
  #         ## extra
  #         fzf-lua
  #         snacks-nvim
  #         mini-nvim
  #         oil-nvim
  #         nvim-web-devicons
  #         neogit
  #         pkgs.neovimPlugins.everforest
  #       ];
  #       orgmode = with pkgs.vimPlugins; [
  #         orgmode 
  #         org-roam-nvim 
  #         sniprun
  #         pkgs.neovimPlugins.org-bullets 
  #       ];
  #       markdown = with pkgs.vimPlugins; [ render-markdown-nvim ];
  #       tex = with pkgs.vimPlugins; [vimtex];
  #       typst = with pkgs.vimPlugins; [ typst-preview-nvim ];
  #     };
  #
  #     # not loaded automatically at startup.
  #     # use with packadd and an autocommand in config to achieve lazy loading
  #     # or a tool for organizing this like lze or lz.n!
  #     # to get the name packadd expects, use the
  #     # `:NixCats pawsible` command to see them all
  #     optionalPlugins = {
  #       general = with pkgs.vimPlugins; [
  #         ## always
  #         nvim-lspconfig
  #         gitsigns-nvim
  #         # diffview-nvim
  #         # advanced-git-search-nvim
  #         # webify-nvim
  #         nvim-surround
  #         nvim-lint
  #         conform-nvim
  #         lazydev-nvim
  #
  #         nvim-treesitter-textobjects
  #         nvim-treesitter.withAllGrammars
  #
  #         ## completion
  #         cmp-cmdline
  #         blink-cmp
  #         blink-compat
  #         colorful-menu-nvim
  #         sqlite-lua
  #
  #         ## extra
  #         fidget-nvim # notifications
  #         which-key-nvim
  #         comment-nvim
  #         undotree
  #         indent-blankline-nvim
  #         vim-startuptime
  #         gx-nvim
  #         grug-far-nvim
  #
  #         neotest
  #         neotest-python
  #         # neotest-elixir
  #
  #         copilot-lua
  #         CopilotChat-nvim
  #       ];
  #       markdown = with pkgs.vimPlugins; [
  #         markdown-preview-nvim
  #       ];
  #     };
  #   };
  #
  #   packageDefinitions = rec {
  #     nvim = {
  #       pkgs,
  #       name,
  #       ...
  #     } @ misc: {
  #       settings = {
  #         suffix-path = true;
  #         suffix-LD = true;
  #         wrapRc = true;
  #         configDirName = "nvim";
  #         aliases = ["nixCats"];
  #         hosts.python3.enable = true;
  #         hosts.node.enable = true;
  #       };
  #       categories = {
  #         markdown = true;
  #         general = true;
  #         ai = true;
  #         nix = true;
  #         lua = true;
  #         python = true;
  #         elixir = true;
  #         tex = true;
  #         typst = true;
  #         orgmode = true;
  #         themer = true;
  #         colorscheme = "everforest";
  #       };
  #     };
  #     vi = pkgs: (nvim pkgs) // { 
  #       settings.wrapRc = false;
  #       settings.aliases = ["regularCats"];
  #     };
  #   };
  #
  #   defaultPackageName = "nvim";
  # in
  #   # see :help nixCats.flake.outputs.exports
  #   forEachSystem (system: let
  #     # and this will be our builder! it takes a name from our packageDefinitions as an argument, and builds an nvim.
  #     nixCatsBuilder =
  #       utils.baseBuilder luaPath {
  #         # we pass in the things to make a pkgs variable to build nvim with later
  #         inherit nixpkgs system dependencyOverlays extra_pkg_config;
  #         # and also our categoryDefinitions and packageDefinitions
  #       }
  #       categoryDefinitions
  #       packageDefinitions;
  #     # call it with our defaultPackageName
  #     defaultPackage = nixCatsBuilder defaultPackageName;
  #
  #     # this pkgs variable is just for using utils such as pkgs.mkShell
  #     # within this outputs set.
  #     pkgs = import nixpkgs {inherit system;};
  #     # The one used to build neovim is resolved inside the builder
  #     # and is passed to our categoryDefinitions and packageDefinitions
  #   in {
  #     # these outputs will be wrapped with ${system} by utils.eachSystem
  #
  #     # this will generate a set of all the packages
  #     # in the packageDefinitions defined above
  #     # from the package we give it.
  #     # and additionally output the original as default.
  #     packages = utils.mkAllWithDefault defaultPackage;
  #
  #     # choose your package for devShell
  #     # and add whatever else you want in it.
  #     devShells = {
  #       default = pkgs.mkShell {
  #         name = defaultPackageName;
  #         packages = [defaultPackage];
  #         inputsFrom = [];
  #         shellHook = ''
  #         '';
  #       };
  #     };
  #   })
  #   // (let
  #     # we also export a nixos module to allow reconfiguration from configuration.nix
  #     nixosModule = utils.mkNixosModules {
  #       moduleNamespace = [defaultPackageName];
  #       inherit
  #         defaultPackageName
  #         dependencyOverlays
  #         luaPath
  #         categoryDefinitions
  #         packageDefinitions
  #         extra_pkg_config
  #         nixpkgs
  #         ;
  #     };
  #     # and the same for home manager
  #     homeModule = utils.mkHomeModules {
  #       moduleNamespace = [defaultPackageName];
  #       inherit
  #         defaultPackageName
  #         dependencyOverlays
  #         luaPath
  #         categoryDefinitions
  #         packageDefinitions
  #         extra_pkg_config
  #         nixpkgs
  #         ;
  #     };
  #   in {
  #     # these outputs will be NOT wrapped with ${system}
  #
  #     # this will make an overlay out of each of the packageDefinitions defined above
  #     # and set the default overlay to the one named here.
  #     overlays =
  #       utils.makeOverlays luaPath {
  #         inherit nixpkgs dependencyOverlays extra_pkg_config;
  #       }
  #       categoryDefinitions
  #       packageDefinitions
  #       defaultPackageName;
  #
  #     nixosModules.default = nixosModule;
  #     homeModules.default = homeModule;
  #
  #     inherit utils nixosModule homeModule;
  #     inherit (utils) templates;
  #   });
}

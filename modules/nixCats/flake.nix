{
  description = "My neovim flake using nixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-everforest" = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      # allowUnfree = true;
    };
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        # This overlay grabs all the inputs named in the format
        # `plugins-<pluginName>`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        (utils.standardPluginOverlay inputs)

        # when other people mess up their overlays by wrapping them with system,
        # you may instead call this function on their overlay.
        # it will check if it has the system in the set, and if so return the desired overlay
        # (utils.fixSystemizedOverlay inputs.codeium.overlays
        #   (system: inputs.codeium.overlays.${system}.default)
        # )
      ];

    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];
        debug = with pkgs; {go = [delve];};
        python = with pkgs; [python3Packages.python-lsp-server];
        elixir = with pkgs; [beam28Packages.elixir-ls];
        tex = with pkgs; [texlab];
        go = with pkgs; [
          gopls
          gotools
          go-tools
          gccgo
        ];
        lua = with pkgs; [lua-language-server];
        nix = {inherit (pkgs) nix-doc nixd alejandra;};
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-nio
        ];
        general = with pkgs.vimPlugins; {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            nvim-notify
          ];
          extra = [
            snacks-nvim
            mini-nvim
            oil-nvim
            nvim-web-devicons
            gx-nvim
            dropbar-nvim
            nvim-ufo
            grug-far-nvim
            render-markdown-nvim
            neogit
          ];
        };
        tex = with pkgs.vimPlugins; [vimtex];
        themer = with pkgs.vimPlugins; (
          builtins.getAttr (categories.colorscheme or "catppuccin") {
            "catppuccin" = catppuccin-nvim;
            "everforest" = pkgs.neovimPlugins.everforest;
          }
        );
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      # or a tool for organizing this like lze or lz.n!
      # to get the name packadd expects, use the
      # `:NixCats pawsible` command to see them all
      optionalPlugins = {
        general = {
          blink = with pkgs.vimPlugins; [
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
            sqlite-lua
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim

            gitsigns-nvim
            # diffview-nvim
            # advanced-git-search-nvim
            # webify-nvim

            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            which-key-nvim
            comment-nvim
            undotree
            indent-blankline-nvim
            vim-startuptime
          ];
        };
        markdown = with pkgs.vimPlugins; [markdown-preview-nvim];
        ai = with pkgs.vimPlugins; [
          copilot-lua
          CopilotChat-nvim
        ];
        debug = with pkgs.vimPlugins; {
          default = [
            nvim-dap
            nvim-dap-ui
            # nvim-dap-view
            nvim-dap-virtual-text
          ];
          go = [nvim-dap-go];
          python = [nvim-dap-python];
        };
        test = with pkgs.vimPlugins; {
          default = [neotest];
          python = [neotest-python];
          elixir = [neotest-elixir];
        };
        dev = with pkgs.vimPlugins; [
          nvim-lint
          conform-nvim
          lazydev-nvim
        ];
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      # environmentVariables = {
      #   test = {
      #     default = {
      #       CATTESTVARDEFAULT = "It worked!";
      #     };
      #     subtest1 = {
      #       CATTESTVAR = "It worked!";
      #     };
      #     subtest2 = {
      #       CATTESTVAR3 = "It didn't work!";
      #     };
      #   };
      # };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      # extraWrapperArgs = {
      #   test = [
      #     '' --set CATTESTVAR2 "It worked again!"''
      #   ];
      # };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages
      # do not forget to set `hosts.python3.enable` in package settings

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = _: [];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        general = [(_: [])];
      };

      extraCats = {
        test = [["test" "default"]];
        debug = [["debug" "default"]];
        go = [["debug" "go"]];
        python = [["python" "debug" "test"]];
        elixir = [["elixir" "test"]];
      };
    };

    packageDefinitions = {
      nixCats = {
        pkgs,
        name,
        ...
      } @ misc: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          aliases = ["nvim"];
          wrapRc = true;
          configDirName = "nvim";
          hosts.python3.enable = true;
          hosts.node.enable = true;
        };
        categories = {
          markdown = true;
          general = true;
          dev = true;
          ai = true;
          nix = true;
          lua = true;
          python = true;
          elixir = true;
          tex = true;
          themer = true;
          colorscheme = "everforest";
          extra = {
            # to keep the categories table from being filled with non category things that you want to pass
            # there is also an extra table you can use to pass extra stuff.
            # but you can pass all the same stuff in any of these sets and access it in lua
            nixdExtras = {
              nixpkgs = ''import ${pkgs.path} {}'';
              # or inherit nixpkgs;
            };
          };
        };
      };
      regularCats = {pkgs, ...} @ misc: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
          configDirName = "nvim";
          aliases = ["vi"];
        };
        categories = {
          markdown = true;
          general = true;
          ai = true;
          nix = true;
          lua = true;
          python = true;
          elixir = true;
          tex = true;
          dev = true;
          themer = true;
          colorscheme = "everforest";
          extra = {
            # nixCats.extra("path.to.val") will perform vim.tbl_get(nixCats.extra, "path" "to" "val")
            # this is different from the main nixCats("path.to.cat") in that
            # the main nixCats("path.to.cat") will report true if `path.to = true`
            # even though path.to.cat would be an indexing error in that case.
            # this is to mimic the concept of "subcategories" but may get in the way of just fetching values.
            nixdExtras = {
              nixpkgs = ''import ${pkgs.path} {}'';
            };
          };
        };
      };
    };

    defaultPackageName = "nixCats";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (system: let
      # and this will be our builder! it takes a name from our packageDefinitions as an argument, and builds an nvim.
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          # we pass in the things to make a pkgs variable to build nvim with later
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
          # and also our categoryDefinitions and packageDefinitions
        }
        categoryDefinitions
        packageDefinitions;
      # call it with our defaultPackageName
      defaultPackage = nixCatsBuilder defaultPackageName;

      # this pkgs variable is just for using utils such as pkgs.mkShell
      # within this outputs set.
      pkgs = import nixpkgs {inherit system;};
      # The one used to build neovim is resolved inside the builder
      # and is passed to our categoryDefinitions and packageDefinitions
    in {
      # these outputs will be wrapped with ${system} by utils.eachSystem

      # this will generate a set of all the packages
      # in the packageDefinitions defined above
      # from the package we give it.
      # and additionally output the original as default.
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}

{ pkgs, ... }:

{
  imports = [
    ./emacs.nix
    ./neovim
  ];

  home.packages = with pkgs; (
    # -*- Data & Configuration Languages -*-#
    [
      #-- nix
      nil
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter

      #-- json like
      taplo # TOML language server / formatter / validator
      nodePackages.yaml-language-server
      actionlint # GitHub Actions linter

      #-- dockerfile
      hadolint # Dockerfile linter
      nodePackages.dockerfile-language-server-nodejs

      #-- markdown
      marksman # language server for markdown
      glow # markdown previewer
      pandoc # document converter
      hugo # static site generator

      #-- sql
      sqlfluff

      #-- protocol buffer
      buf # linting and formatting
    ]
    ++
    #-*- General Purpose Languages -*-#
    [
      #-- c/c++
      cmake
      cmake-language-server
      gnumake
      checkmake
      # c/c++ compiler, required by nvim-treesitter!
      gcc
      gdb
      # c/c++ tools with clang-tools, the unwrapped version won't
      # add alias like `cc` and `c++`, so that it won't conflict with gcc
      # llvmPackages.clang-unwrapped
      clang-tools
      lldb
      vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb - debugger

      #-- python
      pyright # python language server
      (python311.withPackages (
        ps:
        with ps; [
          ruff-lsp
          black # python formatter
          # debugpy

          # my commonly used python packages
          jupyter
          ipython
          pandas
          requests
          pyquery
          pyyaml
          boto3

          ## emacs's lsp-bridge dependenciesge
          # epc
          # orjson
          # sexpdata
          # six
          # setuptools
          # paramiko
          # rapidfuzz
        ]
      ))

      # #-- rust
      # # we'd better use the rust-overlays for rust development
      # pkgs-unstable.rust-analyzer
      # pkgs-unstable.cargo # rust package manager
      # pkgs-unstable.rustfmt
      # pkgs-unstable.clippy # rust linter

      # #-- golang
      # go
      # gomodifytags
      # iferr # generate error handling code for go
      # impl # generate function implementation for go
      # gotools # contains tools like: godoc, goimports, etc.
      # gopls # go language server
      # delve # go debugger

      # # -- java
      # jdk17
      # gradle
      # maven
      # spring-boot-cli
      # jdt-language-server

      # #-- zig
      # zls

      #-- lua
      stylua
      lua-language-server

      #-- bash
      nodePackages.bash-language-server
      shellcheck
      shfmt
    ]
    #-*- Web Development -*-#
    ++ [
      nodePackages.nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      emmet-ls
    ]
  );

  home.sessionVariables.EDITOR = "emacsclient -c -a 'vi'";
  # home.sessionVariables.EDITOR = "emacsclient -nw -a 'vi'";
}

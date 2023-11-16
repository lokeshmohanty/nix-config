# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./features/terminal.nix
    ./features/shell.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  qt = {
    enable = true;
    platformTheme = "qtct";
    # style.name = "breeze";
  };

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "zotero-6.0.27" ];
    };
  };

  home = {
    username = "lokesh";
    homeDirectory = "/home/lokesh";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      EDITOR = "emacsclient -nw a 'vi'";
      BROWSER = "firefox";
    };
    packages = with pkgs; [
      microsoft-edge onlyoffice-bin
      tikzit motrix zotero kdenlive fractal
      vscode.fhs jetbrains.clion jetbrains.pycharm-professional
      fd ledger notmuch zoxide quarto imagemagick
      zathura kitty pcmanfm-qt qalculate-qt
      lxmenu-data               # pcmanfm applicatoins menu

      whitesur-icon-theme capitaine-cursors
      breeze-qt5

      # tree-sitter

      # language servers
      marksman                  # markdown

      texlive.combined.scheme-full
      unityhub zoom-us

      gcc
      lua lua-language-server
      nodejs     # use fnm instead
      micromamba # python3 python311
      (pkgs.python311.withPackages (ps: with ps; [
        jupyter dvc
        numpy pandas matplotlib seaborn
        scikit-learn # tensorflow 
	      pytorch # keras
        transformers

        plotly

        # qtpy pyqt6 pyqt5 pyqt3d
      ]))
    ];
  };
  # xdg = {
  #   enable = true;
  #   userDirs.enable = true;
  #   mimeApps = {
  #     enable = true;
  #   };
  # };

  programs.obs-studio = {
    enable = true;
    # plugins = with pkgs.obs-studio-plugins; [
    #   obs-backgroundremoval
    #   obs-move-transition
    #   advanced-scene-switcher
    # ];
  };
  programs.firefox.enable = true;
  programs.neovim = {
    enable = true; viAlias = true; vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-commentary
      vim-surround
      vim-unimpaired
      nvim-treesitter.withAllGrammars
      mason-nvim
      lazy-nvim
    ];
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [ epkgs.multi-vterm ];
  };
  # programs.keychain = { enable = true; keys = [ "id_ed25519" ]; };
  programs.gh = { enable = true; extensions = [ pkgs.gh-dash ]; };

  services.emacs.enable = true;
  services.gammastep = {
    enable = true;
    temperature = { day = 5000; night = 3000; };
    latitude = 13.0; longitude = 77.5;
    tray = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

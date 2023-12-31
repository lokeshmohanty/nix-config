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
    ./features/terminal
    ./features/editor
    ./features/shell.nix
    ./features/fuzzel.nix
    ./features/lf.nix
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
      BROWSER = "firefox";
    };
    packages = with pkgs; [
      microsoft-edge onlyoffice-bin betterbird
      tikzit motrix zotero kdenlive okular inkscape
      fd ledger notmuch imagemagick zoxide
      pcmanfm-qt qalculate-qt
      lxmenu-data               # pcmanfm applications menu
      # btop

      vscode.fhs discord distrobox
      unityhub zoom-us
      lutris wineWowPackages.waylandFull winetricks

      whitesur-icon-theme capitaine-cursors whitesur-cursors breeze-qt5

      texlive.combined.scheme-full
      gcc ghc nodejs micromamba
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
  # programs.keychain = { enable = true; keys = [ "id_ed25519" ]; };
  programs.gh = { enable = true; extensions = [ pkgs.gh-dash ]; };

  services.gammastep = {
    enable = true;
    temperature = { day = 5000; night = 2500; };
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

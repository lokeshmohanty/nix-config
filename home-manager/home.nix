# This is your home-manage file
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
    # ./features/alacritty.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

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
  };

  home.packages = with pkgs; [
    microsoft-edge firefox anydesk onlyoffice-bin
    tikzit motrix zotero kdenlive
    vscode.fhs jetbrains.clion jetbrains.pycharm-professional
    fd
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-move-transition
      advanced-scene-switcher
    ];
  };
  programs.starship.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      zoxide init fish | source
    '';
    shellAbbrs = {
      e = "emacsclient -nw -a 'nvim'";
      g = "git";
      x = "env -u WAYLAND_DISPLAY";
      nl = "nix-locate";
      ns = "nix search nixpkgs";
      nsh = "nix-shell --command fish -p";
    };
    functions = {
      nr = "nix run nixpkgs#$argv";
    };
    plugins = [ { name = "bass"; src = pkgs.fishPlugins.bass; } ];
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number relativenumber
    '';
    plugins = with pkgs.vimPlugins; [ vim-commentary  vim-surround vim-unimpaired ];
  };
  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519" ];
  };

  services.emacs.startWithUserSession = "graphical";
  services.picom.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

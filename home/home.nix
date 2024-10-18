# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  # qt = {
  #   enable = true;
  #   platformTheme = "gtk";
  #   style.name = "adwaita-dark"; # bb10dark, breeze, motif, plastique
  #   style.package = pkgs.adwaita-qt;
  # };
  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Modern-Ice"; # Bibata-Modern-Amber
  #   };
  #   theme = {
  #     package = pkgs.adw-gtk3;
  #     name = "adw-gtk3";
  #   };
  #   iconTheme = {
  #     package = import ./gruvbox-plus.nix { inherit pkgs; };
  #     name = "GruvboxPlus";
  #   };
  #   # font = {name = "Sans"; size = 11;};
  # };
  # xdg.configFile."gtk-3.0/gtk.css".source = ./config/gtk.css;
  # xdg.configFile."gtk-4.0/gtk.css".source = ./config/gtk.css;

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # my neovim config
      inputs.neovim-config.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "lokesh";
    homeDirectory = "/home/lokesh";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = { BROWSER = "firefox"; };
    # packages = with pkgs; [];
  };

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
  programs.nix-index.enable = true;

  services.gammastep = {
    enable = true;
    temperature = { day = 5000; night = 2500; };
    latitude = 13.0; longitude = 77.5;
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

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.nirinit.nixosModules.nirinit
  ];
  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri: Scrolling based window manager";
  };
  config = lib.mkIf config.desktop.niri.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    environment.sessionVariables.GDK_BACKEND = "wayland";
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xwayland-satellite-unstable
      cage # wayland kiosk
      libsecret
      tofi # configured in home-manager
      wtype
    ];
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    xdg.portal.config.common.default = "gnome";

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    security.soteria.enable = true;

    services.nirinit = {
      enable = true;
      settings = {
        # Map app_id to launch command (useful for PWAs, flatpaks, etc.)
        # launch = {
        #   "chromium-example.com__-Default" = "example-web-app";
        # };
        # Apps to skip during restore
        # skip.apps = [ "steam" ];
      };
    };
  };
}

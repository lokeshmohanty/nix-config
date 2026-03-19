{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.niri.nixosModules.niri ];
  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri: Scrolling based window manager";
  };
  config = lib.mkIf config.desktop.niri.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xwayland-satellite-unstable
      cage # wayland kiosk
      libsecret
    ];
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    security.soteria.enable = true;
  };
}

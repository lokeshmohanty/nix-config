{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri: Scrolling based window manager";
  };
  config = lib.mkIf config.desktop.niri.enable {
    environment.sessionVariables.GDK_BACKEND = "wayland";
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xwayland-satellite
      cage # wayland kiosk
      libsecret
      tofi # configured in home-manager
      wtype
    ];
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    xdg.portal.config.common.default = "gnome";

    programs.niri.enable = true;

    security.soteria.enable = true;
  };
}

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
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xwayland-satellite
    ];
    programs.niri = {
      enable = true;
    };
  };
}

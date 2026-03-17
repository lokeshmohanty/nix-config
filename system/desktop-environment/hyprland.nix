{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland: Tiling window manager";
  };
  config = lib.mkIf config.desktop.hyprland.enable {
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      hyprpolkitagent
      hyprshot # required by noctalia for screenshot
    ];

    programs.xwayland.enable = true;
    programs.hyprland =
      let
        hypr = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;
        package = hypr.hyprland;
        portalPackage = hypr.xdg-desktop-portal-hyprland;
      };
  };
}

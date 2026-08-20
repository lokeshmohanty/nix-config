{ lib, ... }:
{
  imports = [
    ../variables.nix

    ./base.nix
    ./ai.nix
    ./activations.nix
    ./programs.nix

    ./terminal
    ./browser
    ./pdf.nix
    ./editor.nix
    ./rofi.nix
    ./tofi.nix
    ./satty.nix
    ./shell.nix
    ./xdg.nix
    ./stylix.nix
    ./gui.nix
  ];

  stylixConfig.enable = lib.mkDefault true;
  stylixConfig.theme = lib.mkDefault "everforest-dark-hard";
  wallpaper = lib.mkDefault ./../wallpapers/0016.jpg;
}

{ lib, ... }:
{
  imports = [
    ../variables.nix

    ./base.nix
    ./activations.nix

    ./terminal
    ./browser
    ./editor.nix
    ./email.nix
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

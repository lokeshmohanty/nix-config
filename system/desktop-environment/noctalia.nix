# https://docs.noctalia.dev/getting-started/nixos/
{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    gradia # screenshot annotator
    cliphist # clipboard history support
    cava # audio visualizer component
    wlsunset # night light functionality
    evolution-data-server # calendar events
    imagemagick # template processing & wallpaper resizing
    brightnessctl # monitor brightness control

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  services.gnome.evolution-data-server.enable = true; # calendar events
}

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

    # screen-toolkit plugin
    pulseaudio
    zbar
    curl
    translate-shell
    wl-screenrec
    ffmpeg
    gifski

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  services.gnome.evolution-data-server.enable = true; # calendar events
}

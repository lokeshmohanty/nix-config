# https://docs.noctalia.dev/getting-started/nixos/
{
  pkgs,
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

    noctalia
  ];
}

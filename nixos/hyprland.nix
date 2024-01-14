{ pkgs, ... }:


# let
#   configure-gtk = pkgs.writeTextFile {
#     name = "configure-gtk";
#     destination = "/bin/configure-gtk";
#     executable = true;
#     text = let
#       schema = pkgs.gsettings-desktop-schemas;
#       datadir = "${schema}/share/gsettings-schemas/${schema.name}";
#     in ''
#       export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
#       gnome_schema=org.gnome.desktop.interface
#       gsettings set $gnome_schema gtk-theme 'Dracula'
#     '';
#   };
# in
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  environment.systemPackages = with pkgs; [
    pinentry-qt
    waybar dunst libnotify
    fuzzel swaybg waypaper
    networkmanagerapplet mpv vimiv-qt gimp
    grim slurp swappy wl-clipboard
    swayidle swaylock-effects wlogout
    pamixer pavucontrol
    nwg-displays wlr-randr
    qt5.qtwayland qt6.qtwayland
    cliphist pywal hyprpicker
    # udisks2 gvfs
    jmtpfs
    tesseract

    # configure-gtk glib whitesur-gtk-theme
    # gsettings-desktop-schemas
  ];

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.flatpak.enable = true;
}

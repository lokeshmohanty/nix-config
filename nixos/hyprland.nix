{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal xdg-desktop-portal-hyprland
    pinentry-qt
    waybar dunst libnotify
    swaybg waypaper
    networkmanagerapplet mpv vimiv-qt gimp
    grim slurp swappy wl-clipboard
    swayidle swaylock-effects wlogout
    pamixer pavucontrol
    nwg-displays wlr-randr
    qt5.qtwayland qt6.qtwayland
    cliphist pywal hyprpicker
    jmtpfs

    gnome.nautilus
    whitesur-icon-theme capitaine-cursors whitesur-cursors breeze-qt5

    qalculate-qt
    # lxmenu-data gtk3               # pcmanfm applications menu
  ];

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}

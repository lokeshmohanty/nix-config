{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    pinentry-qt
    jmtpfs
    waybar
    dunst
    libnotify
    swaybg
    waypaper
    grim
    slurp
    swappy
    wl-clipboard
    networkmanagerapplet
    swayidle
    swaylock-effects
    wlogout
    cliphist
    hyprpicker
    graphviz
    flameshot

    qt5.qtwayland
    qt6.qtwayland

    # mate.mate-polkit
    howdy
    hyprpolkitagent
    nautilus
    ffmpegthumbnailer
    kdePackages.okular
    # kdePackages.kdenlive
    kdePackages.gwenview
    vlc
    mpv
    imv
    gimp
    pamixer
    pavucontrol
    nwg-displays
    wlr-randr
    qalculate-qt
    ntfs3g
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "start-hyprland";
        user = "lokesh";
      };
    };
  };

  programs.hyprland = let
    hypr = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;
    package = hypr.hyprland;
    portalPackage = hypr.xdg-desktop-portal-hyprland;
  };
  programs.nautilus-open-any-terminal.enable = true;
  programs.nautilus-open-any-terminal.terminal = "${pkgs.kitty}/bin/kitty";
  services.gnome.sushi.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = ["gtk"];
      };
    };
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}

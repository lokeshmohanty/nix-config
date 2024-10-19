{ pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    pinentry-qt jmtpfs
    waybar dunst libnotify swaybg waypaper
    grim slurp swappy wl-clipboard
    networkmanagerapplet
    swayidle swaylock-effects wlogout
    cliphist hyprpicker
    graphviz
    flameshot

    # mate.caja
    mate.mate-polkit
    gnome.nautilus

    # whitesur-icon-theme capitaine-cursors whitesur-cursors breeze-qt5
    qt5.qtwayland qt6.qtwayland

    gwenview vlc
    mpv imv gimp
    pamixer pavucontrol
    nwg-displays wlr-randr
    qalculate-qt
  ];

  # services.xserver = {
  #   enable = true;
  #   displayManager = {
  #     sddm.enable = true;
  #     # sddm.theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
  #     sddm.theme = "where_is_my_sddm_theme";
  #     sddm.wayland.enable = true;
  #     defaultSession = "hyprland";
  #   };
  #   # desktopManager.mate.enable = true;
  # };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "lokesh";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };
  programs.nautilus-open-any-terminal.enable = true;
  programs.nautilus-open-any-terminal.terminal = "${pkgs.foot}/bin/footclient";
  services.gnome.sushi.enable = true;
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

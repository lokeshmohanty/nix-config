{ pkgs, inputs, ... }: {
  ## overlays are better than package overrides
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
  #       postInstall = oldAttrs.postInstall or "" + ''
  #                   substituteInPlace $out/share/wayland-sessions/hyprland.desktop --replace "Exec=Hyprland" "Exec=wrappedhl"        
  #         	'';
  #     });
  #   })
  # ];
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    pinentry-qt jmtpfs
    waybar dunst libnotify swaybg waypaper
    grim slurp swappy wl-clipboard
    networkmanagerapplet
    swayidle swaylock-effects wlogout
    cliphist pywal hyprpicker

    mate.caja mate.mate-polkit

    # whitesur-icon-theme capitaine-cursors whitesur-cursors breeze-qt5
    qt5.qtwayland qt6.qtwayland

    mpv vimiv-qt gimp
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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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

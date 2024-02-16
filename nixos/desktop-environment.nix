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
    # (hyprland.overrideAttrs (prevAttrs: rec {
    #   postInstall =
    #     ''
    #      substituteInPlace $out/share/wayland-sessions/hyprland.desktop --replace "Exec=Hyprland" "Exec=dbus-run-session Hyprland"
    #     '';
    # }))
    where-is-my-sddm-theme

    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
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

    mate.caja
    whitesur-icon-theme capitaine-cursors whitesur-cursors breeze-qt5

    qalculate-qt
  ];

  services.xserver = {
    enable = true;
    displayManager = {
      sddm.enable = true;
      # sddm.theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
      sddm.theme = "where_is_my_sddm_theme";
      sddm.wayland.enable = true;
      defaultSession = "hyprland";
    };
    desktopManager.mate.enable = true;
  };

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

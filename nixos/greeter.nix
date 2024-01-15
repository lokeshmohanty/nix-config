{ pkgs, ... }: {

  # Enable the X11 windowing system.
  # services.xserver.libinput.touchpad.disalbeWhileTyping = false;
  # services.xserver = {
  #   enable = true;

  #   displayManager = {
  #     sddm.enable = true;
  #     sddm.wayland.enable = true;
  #     # sddm.theme = "breeze";
  #     # defaultSession = "Hyprland";
  #   };
  #   # desktopManager.plasma5.enable = true;
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
}

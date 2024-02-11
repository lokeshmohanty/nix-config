{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [ where-is-my-sddm-theme ];
  services.xserver = {
    enable = true;
    displayManager = {
      sddm.enable = true;
      # sddm.theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
      sddm.theme = "where_is_my_sddm_theme";
      defaultSession = "hyprland";
    };
    desktopManager.mate.enable = true;
  };
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.hyprland}/bin/Hyprland";
  #       user = "lokesh";
  #     };
  #   };
  # };
}

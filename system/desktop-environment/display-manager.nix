{ pkgs, inputs, ... }:
{
  imports = [ inputs.sysc-greet.nixosModules.default ];

  services.sysc-greet = {
    enable = true;
    compositor = "niri"; # "hyprland/niri"
  };
  security.pam.services.sysc-greet.enableGnomeKeyring = true;

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
  #       user = "greeter";
  #       # command = "start-hyprland";
  #       # user = "lokesh";
  #     };
  #   };
  # };
  # security.pam.services.greetd.enableGnomeKeyring = true;
}

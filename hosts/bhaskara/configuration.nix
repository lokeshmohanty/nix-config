{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [ ../../system ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };
  nixpkgs.config.nvidia.acceptLicense = true;

  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };
  # services.cloudflared.enable = true;

  # Printing
  # https://nixos.wiki/wiki/Printing
  # Access CUPS interface at http://localhost:631
  services.printing = {
    enable = true;
    # NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup'
    drivers = with pkgs; [ hplipWithPlugin ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  sshServer.enable = true;

  networking.hostName = "bhaskara";
}

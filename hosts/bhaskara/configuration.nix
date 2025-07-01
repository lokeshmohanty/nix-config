{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos
    ../../nixos/ssh.nix
  ];

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

  networking.hostName = "bhaskara";
}

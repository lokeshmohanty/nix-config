{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ../../system ];

  hardware.graphics.enable = true;
  #   hardware.nvidia = {
  #     modesetting.enable = true;
  #     powerManagement.enable = false;
  #     powerManagement.finegrained = false;
  #     open = false;
  #     nvidiaSettings = true;
  #   };
  #   nixpkgs.config = {
  #    nvidia.acceptLicense = true;
  #  };
  gaming.enable = false;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      expat
      libz
      coreutils
      binutils
      libgcc
    ];
    # libraries = [(pkgs.runCommand "steamrun-lib" {} "mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib")];
  };

  desktop.niri.enable = true;

  sshServer.enable = true;
  programs.virt-manager.enable = true;

  networking.hostName = "bose";
}

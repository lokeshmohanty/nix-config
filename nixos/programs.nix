{ config, pkgs, ... }:

{
  ## Documentation: https://github.com/viperML/nh
  ## Video: https://www.youtube.com/watch?v=DnA4xNTrrqY
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/lokesh/Documents/nix-config";
  };
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.fish.enable = true;
  # programs.virt-manager.enable = true;
}

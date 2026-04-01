{ pkgs, ... }:
{
  imports = [
    ../../home
    ./email.nix
  ];
  home.packages = with pkgs; [ slack ];
}

{
  self,
  pkgs,
  ...
}:
{
  imports = [
    ../../home/base.nix
    ../../home/shell.nix
    ../../home/terminal/tmux.nix
    self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
  ];
}

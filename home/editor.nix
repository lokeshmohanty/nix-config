{
  self,
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    pre-commit # for zk notebook formatting and linting
    slides # for zk script to present markdown
    self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
  ];
  programs.zk.enable = true;
  home.sessionVariables.EDITOR = "vi";
  home.sessionVariables.ZK_NOTEBOOK_DIR = "/home/lokesh/Documents/Notebook";
  home.activation.zk = lib.mkAfter ''
    ln -sf /home/lokesh/.nix/config/zk ${config.xdg.configHome}
  '';
}

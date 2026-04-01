{
  self,
  pkgs,
  lib,
  config,
  ...
}:
{
  options.modules.editor.enable = lib.mkEnableOption "editor tooling";

  config = lib.mkIf config.modules.editor.enable {
    home.packages = with pkgs; [
      pre-commit # for zk notebook formatting and linting
      slides # for zk script to present markdown
      self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
    ];
    programs.zk.enable = true;
    home.sessionVariables.EDITOR = "vi";
    home.sessionVariables.ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/Documents/Notebook";
    home.activation.zk = lib.mkAfter ''
      ln -sf ${config.vars.nixDir}/config/zk ${config.xdg.configHome}
    '';
  };
}

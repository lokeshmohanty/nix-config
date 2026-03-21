{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = [ pkgs.rofi ];
  home.activation.rofi = lib.mkAfter ''
    ln -sf "${config.vars.nixDir}/config/rofi" ${config.xdg.configHome}
  '';
}

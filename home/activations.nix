{ lib, config, ... }:
{
  options.modules.activations.enable = lib.mkEnableOption "desktop activation symlinks";

  config = lib.mkIf config.modules.activations.enable {
    home.activation = {
      hyprland = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/hypr ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/waybar ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/wlogout ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/swappy ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/gtk.css ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/icons ${config.xdg.configHome}
      '';
      niri = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/niri ${config.xdg.configHome}
      '';
      noctalia = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/noctalia ${config.xdg.configHome}
      '';
      scripts = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/scripts/* ${config.home.homeDirectory}/.local/bin/
      '';
      inkscape = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/inkscape ${config.xdg.configHome}/inkscape
      '';
      pi = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/pi ${config.home.homeDirectory}/.pi
      '';
    };
  };
}

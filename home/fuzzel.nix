{ pkgs, config, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "Victor Mono:style=Italic:size=15";
      terminal = "kitty";
      dpi-aware = "no";
      width = 50;               # default: 30
      layer = "overlay";
      # exit-on-keyboard-focus-loss = "no";
      # inner-pad = 15;
    };
    settings.colors = with config.colorScheme.palette; {
      background = "${base00}ff"; # RGBA format
      text = "${base06}ff";
      match = "8b39fdff";
      selection-text = "${base06}ff";
      selection-match = "8b39fdff";
      selection = "44475add";
      border = "bd93f9ff";
    };
  };
}

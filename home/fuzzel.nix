{ pkgs, config, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "Victor Mono:style=Italic:size=15";
      terminal = "${pkgs.foot}/bin/footclient";
      dpi-aware = "no";
      width = 50;               # default: 30
      layer = "overlay";
      # exit-on-keyboard-focus-loss = "no";
      # inner-pad = 15;
    };
    settings.colors = {
      background = "1f1d2eff";
      text = "6e6a86ff";
      selection = "908caaff";
      selection-text = "1f1d2eff";
    };
  };
}

{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Victor Mono:style=Italic:size=12";
        dpi-aware = "yes";
        pad = "3x3";
      };
      colors.alpha = 0.5;
    };
  };
}

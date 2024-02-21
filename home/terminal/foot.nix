{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;
    settings.main = {
      term = "xterm-256color";
      font = "Victor Mono:style=Italic:size=15";
    };
    settings.colors = with config.colorScheme.palette; {
      regular0 = "0x${base00}"; # black, ARGB format
      regular1 = "0x${base08}"; # red
      regular2 = "0x${base0B}"; # green
      regular3 = "0x${base0A}"; # yellow
      regular4 = "0x${base0D}"; # blue
      regular5 = "0x${base0E}"; # magenta
      regular6 = "0x${base0C}"; # cyan
      regular7 = "0x${base06}"; # white
      bright0 = "0x${base00}";
      bright1 = "0x${base08}";
      bright2 = "0x${base0B}";
      bright3 = "0x${base09}";
      bright4 = "0x${base0D}";
      bright5 = "0x${base0E}";
      bright6 = "0x${base0C}";
      bright7 = "0x${base06}";

      alpha = 0.7;
      background = "0x${base00}";
      foreground = "0x${base06}";
    };
  };
}

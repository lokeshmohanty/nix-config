{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;
    settings.main = {
      term = "xterm-256color";
      font = "Victor Mono:style=Italic:size=12";
      dpi-aware = "yes";
    };
    # settings.colors = with config.colorScheme.palette; {
    #   regular0 = "${base00}"; # black, RGB format
    #   regular1 = "${base08}"; # red
    #   regular2 = "${base0B}"; # green
    #   regular3 = "${base0A}"; # yellow
    #   regular4 = "${base0D}"; # blue
    #   regular5 = "${base0E}"; # magenta
    #   regular6 = "${base0C}"; # cyan
    #   regular7 = "${base06}"; # white
    #   bright0 = "${base00}";
    #   bright1 = "${base08}";
    #   bright2 = "${base0B}";
    #   bright3 = "${base09}";
    #   bright4 = "${base0D}";
    #   bright5 = "${base0E}";
    #   bright6 = "${base0C}";
    #   bright7 = "${base06}";

    #   alpha = 0.7;
    #   background = "${base00}";
    #   foreground = "${base06}";
    # };
  };
}

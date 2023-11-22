{ pkgs, config, ... }:

{
  programs.kitty = {
    enable = true;
    environment = { "TERM" = "xterm-256color"; };
    font = {
      name = "Victor Mono Italic";
      size = 15;
    };
    theme = "Gruvbox Dark";
    extraConfig = ''background_opacity 0.7'';
    # settings = with config.colorScheme.colors; {
    #   color0 = "0x${base00}"; # black
    #   color1 = "0x${base08}"; # red
    #   color2 = "0x${base0B}"; # green
    #   color3 = "0x${base0A}"; # yellow
    #   color4 = "0x${base0D}"; # blue
    #   color5 = "0x${base0E}"; # magenta
    #   color6 = "0x${base0C}"; # cyan
    #   color7 = "0x${base06}"; # white
    #   color8 = "0x${base00}"; # bright black
    #   color9 = "0x${base08}"; # ...
    #   color10 = "0x${base0B}";
    #   color11 = "0x${base09}";
    #   color12 = "0x${base0D}";
    #   color13 = "0x${base0E}";
    #   color14 = "0x${base0C}";
    #   color15 = "0x${base06}";

    #   background_opacity = "0.7";
    #   background = "0x${base00}";
    #   foreground = "0x${base06}";
    # };
  };
}

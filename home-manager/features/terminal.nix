{ pkgs, config, ... }:

{
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    env.TERM = "xterm-256color";
    window = {
      padding.x = 10;
      opacity = 1.0;
    };
    font = {
      normal.family = "Victor Mono";
      normal.style = "Italic";
      bold.family = "Victor Mono";
      bold.style = "Bold Italic";
      italic.family = "Victor Mono";
      bold_italic.family = "Victor Mono";
      size = 18;
    };
    colors = with config.colorScheme.colors; {
      bright = {
        black = "0x${base00}";
        blue = "0x${base0D}";
        cyan = "0x${base0C}";
        green = "0x${base0B}";
        magenta = "0x${base0E}";
        red = "0x${base08}";
        white = "0x${base06}";
        yellow = "0x${base09}";
      };
      cursor = {
        cursor = "0x${base06}";
        text = "0x${base06}";
      };
      normal = {
        black = "0x${base00}";
        blue = "0x${base0D}";
        cyan = "0x${base0C}";
        green = "0x${base0B}";
        magenta = "0x${base0E}";
        red = "0x${base08}";
        white = "0x${base06}";
        yellow = "0x${base0A}";
      };
      primary = {
        background = "0x${base00}";
        foreground = "0x${base06}";
      };
    };
  };
}

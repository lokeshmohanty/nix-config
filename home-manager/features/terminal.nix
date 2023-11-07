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
      normal.family = "Iosevka Comfy Fixed";
      bold.family = "Iosevka Comfy Fixed";
      italic.family = "Iosevka Comfy Fixed";
      bold_italic.family = "Iosevka Comfy Fixed";
      size = 15;
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

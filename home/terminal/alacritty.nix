{
  pkgs,
  config,
  ...
}: {
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    env.TERM = "xterm-256color";
    window = {
      padding.x = 10;
      opacity = 0.7;
    };
    font = {
      normal.family = "Victor Mono";
      normal.style = "Italic";
      bold.family = "Victor Mono";
      bold.style = "Bold Italic";
      italic.family = "Victor Mono";
      bold_italic.family = "Victor Mono";
      size = 15;
    };
  };
}

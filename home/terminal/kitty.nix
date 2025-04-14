{
  pkgs,
  config,
  ...
}: {
  programs.kitty = {
    enable = true;
    environment = {"TERM" = "xterm-256color";};
    font = {
      name = "Victor Mono Italic";
      size = 15;
    };
    theme = "Gruvbox Dark";
    extraConfig = ''background_opacity 0.7'';
  };
}

{
  pkgs,
  config,
  ...
}: {
  programs.kitty = {
    enable = true;
    environment = {"TERM" = "xterm-256color";};
    settings = {
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";
      forward_remote_control = "yes";
    };
    shellIntegration.enableFishIntegration = true;
    # font = {
    #   name = "Victor Mono Italic";
    #   size = 15;
    # };
    # theme = "Gruvbox Dark";
    # extraConfig = ''background_opacity 0.7'';
  };
}

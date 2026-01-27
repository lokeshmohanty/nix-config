{
  pkgs,
  config,
  ...
}: {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";
      forward_remote_control = "yes";
      confirm_os_window_close = "2";
    };
    shellIntegration.enableFishIntegration = true;
  };
}

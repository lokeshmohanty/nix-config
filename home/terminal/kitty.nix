{
  pkgs,
  config,
  ...
}: {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    actionAliases = {
      "launch_tab" = "launch --cwd=current --type=tab";
      "launch_window" = "launch --cwd=current --type=os-window";
    };
    settings = {
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";
      forward_remote_control = "yes";
      confirm_os_window_close = "2";
    };
    shellIntegration.enableFishIntegration = true;
  };
}

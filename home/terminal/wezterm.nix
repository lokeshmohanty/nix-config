{ pkgs, config, ... }:

{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
  };
}

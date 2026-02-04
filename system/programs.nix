{
  config,
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.wayprompt;
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.fish.enable = true;
  # programs.virt-manager.enable = true;
}

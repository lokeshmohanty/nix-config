{
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-egui;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;
  # programs.virt-manager.enable = true;
}

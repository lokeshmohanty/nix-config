{
  pkgs,
  ...
}:
{
  virtualisation = {
    # docker = {
    #   enable = true;
    #   rootless.enable = true;
    #   rootless.setSocketVariable = true;
    # };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    # waydroid.enable = true;
    # waydroid.package = pkgs.waydroid-nftables;
  };
}

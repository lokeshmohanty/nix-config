{
  pkgs,
  lib,
  ...
}: {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.gvfs.enable = true; # mount, trash and other functionalities
  services.tumbler.enable = true; # thumbnail support for images
  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  # Capslock as Control + Escape, Escape as Capslock
  services.interception-tools = {
    enable = true;
    plugins = lib.mkForce [
      pkgs.interception-tools-plugins.caps2esc
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
    '';
  };

  # https://nixos.wiki/wiki/Printing
  # Access CUPS interface at http://localhost:631
  services.printing = {
    enable = true;
    # Run 'sudo -E hp-setup' or 'sudo hp-setup -i -a'
    drivers = with pkgs; [ hplipWithPlugin ]; 
  };

  services.blueman.enable = true;
  services.flatpak.enable = true;
  services.tailscale.enable = true;
  services.cloudflare-warp.enable = true;
  services.cloudflared.enable = true;
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
    openFirewall = true;
    # settings = {
    #   "load printers" = "yes";
    #   "printing" = "cups";
    #   "printcap name" = "cups";
    # };
    # "printers" = {
    #   "comment" = "All Printers";
    #   "path" = "/var/spool/samba";
    #   "public" = "yes";
    #   "browseable" = "yes";
    #   # to allow user 'guest account' to print.
    #   "guest ok" = "yes";
    #   "writable" = "no";
    #   "printable" = "yes";
    #   "create mode" = 0700;
    # };
  };
  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];
}

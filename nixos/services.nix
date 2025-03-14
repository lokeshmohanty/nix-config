{ pkgs, lib, ... }: {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.gvfs.enable = true;  # mount, trash and other functionalities
  services.tumbler.enable = true;  # thumbnail support for images
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
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
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
    # drivers = with pkgs; [ hplipWithPlugin ]; 
  };
  services.tailscale.enable = true;

  services.blueman.enable = true;
  services.flatpak.enable = true;
}

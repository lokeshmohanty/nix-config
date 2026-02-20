{
  pkgs,
  lib,
  ...
}: {
  # Enable sound with pipewire.
  musnix.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-hdmi-fix.lua" ''
        rule = {
          matches = {
            {
              { "device.name", "matches", "alsa_card.*" },
            },
          },
          apply_properties = {
            ["api.alsa.use-acp"] = true,
          },
        }
        table.insert(alsa_monitor.rules, rule)
      '')
    ];
  };
  services.gvfs.enable = true; # mount, trash and other functionalities
  services.tumbler.enable = true; # thumbnail support for images
  services.transmission.openRPCPort = true; # required for motrix
  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };
  services.fwupd.enable = true; # firmware update manager

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
  services.tailscale.enable = true;

  services.blueman.enable = true;
  services.flatpak.enable = true;
}

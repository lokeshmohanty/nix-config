{ pkgs, lib, ... }: {
  # services.teamviewer.enable = true;
  services.gvfs.enable = true;  # mount, trash and other functionalities
  services.tumbler.enable = true;  # thumbnail support for images
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    localuser = null;
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
          NAME: "AT Translated Set 2 keyboard"
          EVENTS:
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
    '';
  };
  services.printing = {
    enable = true;
    browsing = true;
  };
  services.blueman.enable = true;
  services.flatpak.enable = true;
}

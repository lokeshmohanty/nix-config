{ ... }: {
  security = {
    rtkit.enable = true;
    pam.services.swaylock = {};
    pam.services.sddm.enableGnomeKeyring = true;
    # polkit.enable = true;
  };
}

{ ... }: {
  security = {
    rtkit.enable = true;
    pam.services.swaylock = {};
    pam.services.greetd.enableGnomeKeyring = true;
    # polkit.enable = true;
  };
}

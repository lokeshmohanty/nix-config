{...}: {
  security = {
    rtkit.enable = true;
    # polkit.enable = true;
    pam.services.swaylock = {};
    pam.services.greetd.enableGnomeKeyring = true;
    pam.howdy.enable = true;
  };
}

{...}: {
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.swaylock = {};
    pam.services.greetd.enableGnomeKeyring = true;
  };
  # services.howdy.enable = true;
  services.gnome.gnome-keyring.enable = true;
}

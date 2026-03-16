{ ... }:
{
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
  # services.howdy.enable = true;
  services.gnome.gnome-keyring.enable = true;
}

{
  config,
  lib,
  mkCalendar,
  mkContact,
  mkEmail,
  ...
}:
(import ../../home/email/accounts.nix {
  inherit config lib mkCalendar mkContact mkEmail;
}) {
  main = {
    address = "lokesh1197@gmail.com";
    flavor = "gmail";
    signature = ''
      Lokesh Mohanty
    '';
    primary = true;
  };

  personal = {
    address = "me.lokeshmohanty@gmail.com";
    flavor = "gmail";
    signature = "Lokesh Mohanty";
  };

  zenteiq = {
    address = "lokeshmohanty@zenteiq.com";
    flavor = "gmail";
    signature = "Lokesh Mohanty";
  };

  iisc = {
    address = "lokeshm@iisc.ac.in";
    flavor = "outlook";
    signature = ''
      Lokesh Mohanty
      Indian Institute of Science
    '';
  };
}

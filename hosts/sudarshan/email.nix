{
  config,
  lib,
  mkEmailAccount,
  ...
}:
{
  modules.email.enable = true;

  ########################################
  # EMAIL ACCOUNTS (SOURCE OF TRUTH)
  ########################################
  accounts.contact = {
    basePath = "${config.xdg.dataHome}/contacts";
    accounts.main = {
      # local = {
      #   type = "filesystem";
      #   path = "${config.xdg.dataHome}/.contacts/main";
      #   fileExt = ".vcf";
      # };
      remote = {
        type = "carddav";
        url = "https://www.googleapis.com/carddav/v1/principals/lokesh1197@gmail.com/lists/";
        userName = "lokesh1197@gmail.com";
        passwordCommand = [
          "pass"
          "mutt/lokesh1197@gmail.com"
        ];
      };
      khard.enable = true;
      pimsync = {
        enable = true;
        # collections = [ "remote" "local" ];
        # conflictResolution = "remote wins";
      };
    };
  };
  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/Mail";

    accounts = lib.mapAttrs mkEmailAccount {
      main = {
        primary = true;
        address = "lokesh1197@gmail.com";
        flavor = "gmail.com";
        passwordCommand = "pass mutt/lokesh1197@gmail.com";
      };
      zenteiq = {
        address = "lokeshmohanty@zenteiq.com";
        flavor = "gmail.com";
        passwordCommand = "pass mutt/lokeshmohanty@zenteiq.com";
      };
      personal = {
        address = "me.lokeshmohanty@gmail.com";
        flavor = "gmail.com";
        passwordCommand = "pass mutt/me.lokeshmohanty@gmail.com";
      };
      iisc = {
        address = "lokeshm@iisc.ac.in";
        flavor = "outlook.office365.com";
        passwordCommand = "oauthman token iisc";
        oauth = true;
        mbsyncExtraConfig = {
          channel.Patterns = [ "INBOX" ];
        };
        imapnotify.enable = false;
        signatureText = ''
          Lokesh Mohanty
          Indian Institute of Science
        '';
      };
    };
  };
}

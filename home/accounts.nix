{ config, lib, ... }:
let
  googleClientIdCommand = [
    "oauthman"
    "client-id"
    "--provider"
    "gmail"
    "--client"
    "thunderbird"
  ];
  googleClientSecretCommand = [
    "oauthman"
    "client-secret"
    "--provider"
    "gmail"
    "--client"
    "thunderbird"
  ];
  googleTokenFile = kind: name: "${config.xdg.stateHome}/vdirsyncer/${kind}-${name}.token";

  accountDefs = {
    main = {
      address = "lokesh1197@gmail.com";
      passwordCommand = "pass mutt/lokesh1197@gmail.com";
      mail = {
        flavor = "gmail.com";
        imapHost = "imap.gmail.com";
        smtpHost = "smtp.gmail.com";
      };
      contacts = {
        enable = true;
        remote.type = "google_contacts";
        vdirsyncer = {
          tokenFile = googleTokenFile "contacts" "main";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
      calendar = {
        enable = true;
        remote.type = "google_calendar";
        vdirsyncer = {
          tokenFile = googleTokenFile "calendar" "main";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
    };
    zenteiq = {
      address = "lokeshmohanty@zenteiq.com";
      passwordCommand = "pass mutt/lokeshmohanty@zenteiq.com";
      mail = {
        flavor = "gmail.com";
        imapHost = "imap.gmail.com";
        smtpHost = "smtp.gmail.com";
      };
      contacts = {
        enable = true;
        remote.type = "google_contacts";
        vdirsyncer = {
          tokenFile = googleTokenFile "contacts" "zenteiq";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
      calendar = {
        enable = true;
        remote.type = "google_calendar";
        vdirsyncer = {
          tokenFile = googleTokenFile "calendar" "zenteiq";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
    };
    personal = {
      address = "me.lokeshmohanty@gmail.com";
      passwordCommand = "pass mutt/me.lokeshmohanty@gmail.com";
      mail = {
        flavor = "gmail.com";
        imapHost = "imap.gmail.com";
        smtpHost = "smtp.gmail.com";
      };
      contacts = {
        enable = true;
        remote.type = "google_contacts";
        vdirsyncer = {
          tokenFile = googleTokenFile "contacts" "personal";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
      calendar = {
        enable = true;
        remote.type = "google_calendar";
        vdirsyncer = {
          tokenFile = googleTokenFile "calendar" "personal";
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
    };
    iisc = {
      address = "lokeshm@iisc.ac.in";
      passwordCommand = "oauthman token iisc";
      mail = {
        flavor = "outlook.office365.com";
        oauth = true;
        imapHost = "outlook.office365.com";
        smtpHost = "smtp.office365.com";
        mbsyncExtraConfig.channel.Patterns = [ "INBOX" ];
        imapnotify.enable = false;
      };
      signatureText = ''
        Lokesh Mohanty
        Indian Institute of Science
      '';
    };
  };

  selectAccounts =
    names:
    lib.genAttrs names (
      name: accountDefs.${name} or (throw "Unknown account '${name}' in home/accounts.nix")
    );

  setPrimaryAccount =
    primary: accounts: lib.mapAttrs (name: account: account // { primary = name == primary; }) accounts;
in
{
  config._module.args = {
    inherit accountDefs selectAccounts setPrimaryAccount;
  };
}

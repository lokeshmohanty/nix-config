{
  config,
  lib,
  mkCalendar,
  mkContact,
  mkEmail,
}:
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

  flavorDefaults = {
    gmail = name: {
      passwordCommand = "oauthman token ${name}";
      mail = {
        flavor = "gmail.com";
        oauth = true;
        imapHost = "imap.gmail.com";
        smtpHost = "smtp.gmail.com";
      };
      folders = {
        inbox = "Inbox";
        sent = "[Gmail]/Sent Mail";
        drafts = "[Gmail]/Drafts";
        trash = "[Gmail]/Trash";
      };
      contacts = {
        enable = true;
        remote.type = "google_contacts";
        vdirsyncer = {
          tokenFile = googleTokenFile "contacts" name;
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
      calendar = {
        enable = true;
        remote.type = "google_calendar";
        vdirsyncer = {
          tokenFile = googleTokenFile "calendar" name;
          clientIdCommand = googleClientIdCommand;
          clientSecretCommand = googleClientSecretCommand;
        };
      };
    };

    outlook = name: {
      passwordCommand = "oauthman token ${name}";
      mail = {
        flavor = "outlook.office365.com";
        oauth = true;
        imapHost = "outlook.office365.com";
        smtpHost = "smtp.office365.com";
      };
      folders = {
        inbox = "Inbox";
        sent = "Sent Items";
        drafts = "Drafts";
        trash = "Deleted Items";
      };
    };
  };

  normalizeAccount =
    name: account:
    let
      flavor =
        account.flavor or (throw "Missing flavor for account '${name}' in home/email/accounts.nix");
      defaults =
        flavorDefaults.${flavor}
          or (throw "Unknown flavor '${flavor}' for account '${name}' in home/email/accounts.nix");
      extra = builtins.removeAttrs account [
        "flavor"
        "signature"
      ];
    in
    lib.recursiveUpdate (defaults name) extra
    // {
      signatureText = account.signature or "Lokesh Mohanty";
    };
in
defs:
let
  accounts = lib.mapAttrs normalizeAccount defs;
in
{
  modules.email.enable = true;

  accounts.contact = {
    basePath = "${config.xdg.dataHome}/contacts";
    accounts = lib.mapAttrs mkContact (
      lib.filterAttrs (_: account: account.contacts.enable or false) accounts
    );
  };

  accounts.calendar = {
    basePath = "${config.xdg.dataHome}/calendars";
    accounts = lib.mapAttrs mkCalendar (
      lib.filterAttrs (_: account: account.calendar.enable or false) accounts
    );
  };

  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/Mail";
    accounts = lib.mapAttrs mkEmail accounts;
  };
}

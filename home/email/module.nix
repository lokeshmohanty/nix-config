{
  config,
  pkgs,
  self,
  lib,
  ...
}:
let
  cfg = config.modules.email;

  accountTagQuery = account: "(to:${account.address} or from:${account.address})";
  emailAccounts = lib.attrValues (
    lib.filterAttrs (_: account: account.notmuch.enable or false) config.accounts.email.accounts
  );

  mkEmail = name: account: {
    inherit (account) address;
    primary = account.primary or false;
    realName = account.realName or "Lokesh Mohanty";
    userName = account.userName or account.address;
    flavor = account.mail.flavor;
    passwordCommand = account.passwordCommand;

    imap.authentication = if account.mail.oauth or false then "xoauth2" else "app";
    smtp.authentication = if account.mail.oauth or false then "xoauth2" else "app";

    mbsync = {
      enable = true;
      create = "maildir";
      expunge = "both";
      remove = "both";
      extraConfig =
        (
          if account.mail.oauth or false then
            { account.AuthMechs = "XOAUTH2"; }
          else
            { account.AuthMechs = "PLAIN"; }
        )
        // (account.mail.mbsyncExtraConfig or { });
    };

    msmtp.enable = true;
    msmtp.extraConfig = { auth = "xoauth2"; };

    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotify = "mbsync ${name}";
      onNotifyPost = ''
        ${pkgs.notmuch}/bin/notmuch new
        msg=$(${pkgs.notmuch}/bin/notmuch search --limit=1 --sort=newest-first --format=json tag:inbox and tag:${name} | ${pkgs.jq}/bin/jq '.[0]["authors"], .[0]["subject"]' | ${pkgs.coreutils}/bin/paste -d': ' - -)
        if [ -n "$msg" ]; then ${pkgs.libnotify}/bin/notify-send "(${name}) $msg"; fi
      '';
      extraConfig = { xoAuth2 = true; };
    }
    // (account.mail.imapnotify or { });

    notmuch.enable = true;

    signature = {
      showSignature = "append";
      text = account.signatureText or "Lokesh Mohanty";
    };
  };

  mkContact = _: account: {
    local = account.contacts.local or { };
    remote = account.contacts.remote;
    khard = {
      enable = true;
      type = "vdir";
      addressbooks = [ "default" ];
    }
    // (account.contacts.khard or { });
    vdirsyncer = {
      enable = true;
      collections = [
        "from a"
        "from b"
      ];
    }
    // (account.contacts.vdirsyncer or { });
  };

  mkCalendar = _: account: {
    primary = account.primary or false;
    local = account.calendar.local or { };
    remote = account.calendar.remote;
    khal = {
      enable = true;
    }
    // (account.calendar.khal or { });
    vdirsyncer = {
      enable = true;
      collections = [
        "from a"
        "from b"
      ];
      metadata = [
        "displayname"
        "color"
      ];
    }
    // (account.calendar.vdirsyncer or { });
  };
in
{
  options.modules.email.enable = lib.mkEnableOption "email tooling and shared account helpers";

  config = lib.mkMerge [
    {
      _module.args = {
        inherit mkEmail mkContact mkCalendar;
      };
    }

    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        aspell
        oauth2ms
        w3m
      ] ++ [
        self.packages.${pkgs.stdenv.hostPlatform.system}.oauthman
      ];

      programs.khard = {
        enable = true;
        settings = {
          general = {
            default_action = "list";
            editor = [ "nvim" "-i" "NONE" ];
          };
          "contact table" = {
            display = "formatted_name";
            preferred_email_address_type = [ "pref" "work" "home" ];
          };
        };
      };

      programs.mbsync = {
        enable = true;
        package = pkgs.isync.override {
          withCyrusSaslXoauth2 = true;
        };
      };

      programs.msmtp.enable = true;
      programs.khal.enable = true;
      programs.vdirsyncer.enable = true;

      programs.notmuch = {
        enable = true;
        new.tags = [
          "new"
          "unread"
        ];
        search.excludeTags = [
          "deleted"
          "spam"
          "trash"
        ];
        hooks.postNew = ''
          notmuch tag --batch <<EOM
          ${lib.concatStringsSep "\n" (
            map (account: "+${account.name} -- tag:new and (${accountTagQuery account})") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (account: "+inbox -- tag:new and path:${account.name}/${account.folders.inbox}/cur") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (account: "+sent -inbox -unread -- tag:new and path:${account.name}/${account.folders.sent}/cur") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (account: "+draft -inbox -unread -- tag:new and path:${account.name}/${account.folders.drafts}/cur") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (account: "+trash +deleted -inbox -unread -- tag:new and path:${account.name}/${account.folders.trash}/cur") emailAccounts
          )}
          -new -- tag:new
          EOM
        '';
      };

      services.imapnotify.enable = true;
      services.imapnotify.path = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.oauthman
        pkgs.libnotify
      ];

      services.vdirsyncer = {
        enable = true;
        frequency = "*:0/15";
      };
    })
  ];
}

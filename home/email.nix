{
  config,
  pkgs,
  self,
  lib,
  ...
}:
let
  cfg = config.modules.email;

  defaultVirtualMailboxes = [
    {
      name = "Inbox";
      query = "tag:inbox";
      type = "threads";
    }
    {
      name = "Unread";
      query = "tag:unread and not tag:trash";
      type = "threads";
    }
    {
      name = "Flagged";
      query = "tag:flagged and not tag:trash";
      type = "threads";
    }
    {
      name = "Sent";
      query = "tag:sent";
      type = "threads";
    }
    {
      name = "Drafts";
      query = "tag:draft";
      type = "threads";
    }
    {
      name = "Archive";
      query = "not tag:inbox and not tag:sent and not tag:draft and not tag:trash";
      type = "threads";
    }
  ];

  pathQuery = account: folder: "path:${account.name}/${folder}/**";
  emailAccounts = lib.attrValues (
    lib.filterAttrs (_: account: account.notmuch.enable or false) config.accounts.email.accounts
  );

  notmuchPostNewScript = pkgs.writeShellScript "notmuch-post-new" ''
    set -eu

    ${lib.concatStringsSep "\n\n" (
      map (account: ''
        notmuch tag +inbox -- ${lib.escapeShellArg (pathQuery account account.folders.inbox)}
        notmuch tag +sent -inbox -unread -- ${lib.escapeShellArg (pathQuery account account.folders.sent)}
        notmuch tag +draft -inbox -unread -- ${lib.escapeShellArg (pathQuery account account.folders.drafts)}
        notmuch tag +trash +deleted -inbox -unread -- ${lib.escapeShellArg (pathQuery account account.folders.trash)}
      '') emailAccounts
    )}
  '';

  khardAddressbook = name: account: ''
    [[${name}]]
    path = ${account.local.path}/default
  '';

  khardConfig =
    let
      khardAccounts = lib.filterAttrs (_: account: account.khard.enable) config.accounts.contact.accounts;
    in
    ''
      [addressbooks]
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList khardAddressbook khardAccounts)}

      [contact table]
      display=formatted_name
      preferred_email_address_type=pref, work, home

      [general]
      default_action=list
      editor=nvim, -i, NONE
    '';

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

    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotify = "mbsync ${name}";
      onNotifyPost = "notmuch new";
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
      home.packages =
        with pkgs;
        [
          aspell
          khard
          oauth2ms
          w3m
        ]
        ++ [
          self.packages.${pkgs.stdenv.hostPlatform.system}.oauthman
        ];

      xdg.configFile."khard/khard.conf".text = khardConfig;

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
        new.tags = [ "unread" ];
        search.excludeTags = [
          "deleted"
          "spam"
          "trash"
        ];
        hooks.postNew = "${notmuchPostNewScript}";
      };

      services.imapnotify.enable = true;

      systemd.user.services.vdirsyncer-sync = {
        Unit = {
          Description = "Sync contacts and calendars with vdirsyncer";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "vdirsyncer sync";
        };
      };

      systemd.user.timers.vdirsyncer-sync = {
        Unit.Description = "Periodic contacts and calendar sync";
        Timer = {
          OnBootSec = "2m";
          OnUnitActiveSec = "15m";
          Persistent = true;
          Unit = "vdirsyncer-sync.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    })
  ];
}

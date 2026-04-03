{
  config,
  pkgs,
  self,
  lib,
  ...
}:
let
  cfg = config.modules.email;
  vdirsyncerCommand = "${pkgs.vdirsyncer}/bin/vdirsyncer";
  vdirsyncerSyncCommand = "${vdirsyncerCommand} sync";
  enabledAttrs = f: attrs: lib.filterAttrs (_: v: v != null) (lib.mapAttrs f attrs);
  khardSettings = ''
    [contact table]
    display=formatted_name
    preferred_email_address_type=pref, work, home

    [general]
    default_action=list
    editor=nvim, -i, NONE
  '';
  googleClientIdCommand = [ "oauthman" "client-id" "--provider" "gmail" "--client" "thunderbird" ];
  googleClientSecretCommand = [ "oauthman" "client-secret" "--provider" "gmail" "--client" "thunderbird" ];
  mkGoogleTokenFile = kind: name: "${config.xdg.stateHome}/vdirsyncer/${kind}-${name}.token";
  mkPasswordCommand =
    passwordCommand: if builtins.isString passwordCommand then lib.splitString " " passwordCommand else passwordCommand;
  isGoogleAccount = flavor: flavor == "gmail.com";
  mkGoogleVdirsyncer =
    kind: name: attrs:
    attrs
    // {
      tokenFile = attrs.tokenFile or mkGoogleTokenFile kind name;
      clientIdCommand = attrs.clientIdCommand or googleClientIdCommand;
      clientSecretCommand = attrs.clientSecretCommand or googleClientSecretCommand;
    };
  mkRemote =
    {
      name,
      address,
      flavor ? null,
      passwordCommand,
      remote,
      googleType,
      defaultType,
    }:
    let
      remoteType = remote.type or (if isGoogleAccount flavor then googleType else defaultType);
    in
    { type = remoteType; }
    // lib.optionalAttrs (remoteType != googleType) {
      url = remote.url or (throw "${name} is missing remote.url");
      userName = remote.userName or address;
      passwordCommand = remote.passwordCommand or mkPasswordCommand passwordCommand;
    };
  mkVdirsyncerOpts =
    {
      kind,
      name,
      flavor ? null,
      remote,
      vdirsyncer ? { },
      defaults ? { },
    }:
    let
      googleType = "google_${kind}";
      attrs = defaults // { enable = vdirsyncer.enable or true; };
    in
    if (remote.type or null) == googleType || (remote.type or null) == null && isGoogleAccount flavor then
      mkGoogleVdirsyncer kind name (attrs // vdirsyncer)
    else
      attrs // vdirsyncer;

  mkEmailAccount =
    name:
    {
      address,
      flavor,
      passwordCommand,
      oauth ? false,
      realName ? "Lokesh Mohanty",
      primary ? false,
      signatureText ? "Lokesh Mohanty",
      mbsyncExtraConfig ? { },
      contact ? null,
      calendar ? null,
      imapnotify ? {
        enable = true;
        boxes = [ "INBOX" ];
        onNotify = "${pkgs.isync}/bin/mbsync ${name}";
        onNotifyPost = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
      },
    }:
    {
      inherit address realName primary;
      inherit flavor passwordCommand imapnotify;

      userName = address;
      imap.authentication = if oauth then "xoauth2" else "app";
      smtp.authentication = if oauth then "xoauth2" else "app";

      mbsync = {
        enable = true;
        create = "maildir";
        extraConfig =
          (if oauth then { account.AuthMechs = "XOAUTH2"; } else { account.AuthMechs = "PLAIN"; })
          // mbsyncExtraConfig;
      };

      msmtp.enable = true;
      aerc.enable = true;
      notmuch.enable = true;

      signature = {
        showSignature = "append";
        text = signatureText;
      };
    };

  mkContactAccount =
    name:
    {
      address,
      flavor ? null,
      passwordCommand,
      contact ? null,
      ...
    }:
    if contact == null || !(contact.enable or false) then
      null
    else
      let
        contactKhard = contact.khard or { };
      in
      {
        local = contact.local or { };
        remote = mkRemote {
          inherit name address flavor passwordCommand;
          remote = contact.remote or { };
          googleType = "google_contacts";
          defaultType = "carddav";
        };
        khard.enable = contactKhard.enable or true;
        khard.type = contactKhard.type or "vdir";
        khard.addressbooks = contactKhard.addressbooks or [ "default" ];
        vdirsyncer = mkVdirsyncerOpts {
          kind = "contacts";
          inherit name flavor;
          remote = contact.remote or { };
          vdirsyncer = contact.vdirsyncer or { };
          defaults = {
            collections = [
              "from a"
              "from b"
            ];
          };
        }
        ;
      };

  mkCalendarAccount =
    name:
    {
      address,
      flavor ? null,
      passwordCommand,
      primary ? false,
      calendar ? null,
      ...
    }:
    if calendar == null || !(calendar.enable or false) then
      null
    else
      let
        calendarKhal = calendar.khal or { };
      in
      {
        inherit primary;
        local = calendar.local or { };
        remote = mkRemote {
          inherit name address flavor passwordCommand;
          remote = calendar.remote or { };
          googleType = "google_calendar";
          defaultType = "caldav";
        };
        khal.enable = calendarKhal.enable or true;
        vdirsyncer = mkVdirsyncerOpts {
          kind = "calendar";
          inherit name flavor;
          remote = calendar.remote or { };
          vdirsyncer = calendar.vdirsyncer or { };
          defaults = {
            collections = [
              "from a"
              "from b"
            ];
            metadata = [
              "displayname"
              "color"
            ];
          };
        };
      };
in
{
  options.modules.email.enable = lib.mkEnableOption "email tooling and shared account helpers";

  config = lib.mkMerge [
    {
      _module.args.mkEmailAccount = mkEmailAccount;
      _module.args.mkContactAccount = mkContactAccount;
      _module.args.mkCalendarAccount = mkCalendarAccount;
      _module.args.enabledAttrs = enabledAttrs;
    }

    (lib.mkIf cfg.enable {
      home.packages =
        with pkgs;
        [
          w3m
          pandoc
          oauth2ms
          aspell
          khard
        ]
        ++ [
          self.packages.${pkgs.stdenv.hostPlatform.system}.oauthman
        ];

      xdg.configFile."khard/khard.conf".text =
        let
          khardAccounts = lib.filterAttrs (_: account: account.khard.enable) config.accounts.contact.accounts;
          khardAddressbook =
            name: account: ''
              [[${name}]]
              path = ${account.local.path}/default
            '';
        in
        ''
          [addressbooks]
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList khardAddressbook khardAccounts)}

          ${khardSettings}
        '';

      programs.aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
        };
      };

      programs.notmuch = {
        enable = true;
        hooks.postNew = ''
          notmuch tag -new -- tag:new
          notmuch tag +inbox +unread -- tag:unread

          # priority
          # notmuch tag +important -- 'from:advisor@ OR from:prof@'
          # notmuch tag +work -- 'from:@iisc.ac.in'
          # notmuch tag +zenteiq -- 'from:@zentieq.com'
          #
          # # remove noise
          # notmuch tag +promo -inbox -- 'subject:unsubscribe'
        '';
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

      services.imapnotify.enable = true;

      systemd.user.services.vdirsyncer-sync = {
        Unit = {
          Description = "Sync contacts and calendars with vdirsyncer";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = vdirsyncerSyncCommand;
        };
      };

      systemd.user.timers.vdirsyncer-sync = {
        Unit = {
          Description = "Periodic contacts and calendar sync";
        };
        Timer = {
          OnBootSec = "2m";
          OnUnitActiveSec = "15m";
          Persistent = true;
          Unit = "vdirsyncer-sync.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    })
  ];
}

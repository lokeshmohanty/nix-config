{
  config,
  pkgs,
  self,
  lib,
  ...
}:
let
  cfg = config.modules.email;

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
in
{
  options.modules.email.enable = lib.mkEnableOption "email tooling and shared account helpers";

  config = lib.mkMerge [
    {
      _module.args.mkEmailAccount = mkEmailAccount;
    }

    (lib.mkIf cfg.enable {
      home.packages =
        with pkgs;
        [
          w3m
          pandoc
          oauth2ms
          aspell
        ]
        ++ [
          self.packages.${pkgs.stdenv.hostPlatform.system}.oauthman
        ];

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
      programs.pimsync.enable = true;
      programs.khard = {
        enable = true;
        settings = {
          general = {
            default_action = "list";
            editor = [
              "nvim"
              "-i"
              "NONE"
            ];
          };
          "contact table" = {
            display = "formatted_name";
            preferred_email_address_type = [
              "pref"
              "work"
              "home"
            ];
          };
        };
      };
    })
  ];
}

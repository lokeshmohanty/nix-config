{
  config,
  pkgs,
  self,
  lib,
  ...
}:
let
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
        # expunge = "both";
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
  ########################################
  # PACKAGES
  ########################################
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

  ########################################
  # Programs
  ########################################
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      #   viewer = {
      #     "text/plain" = "less -R";
      #     "text/html" = "w3m -I %{charset} -T text/html";
      #   };
      #   compose = {
      #     editor = "sh -c 'nvim \"$1\" && ${config.vars.nixDir}/scripts/email-md.sh \"$1\"'";
      #     address-book-cmd = "khard email --parsable";
      #   };
      #   ui = {
      #     index-format = "%D %-20.20n %Z %s";
      #     threading-enabled = true;
      #   };
      #   bindings = {
      #     j = "next";
      #     k = "prev";
      #     a = ":modify-labels -inbox -unread<enter>";
      #     d = ":delete<enter>";
      #     r = "reply";
      #
      #     # per-account compose
      #     "cm" = ":compose -A main<enter>";
      #     "ci" = ":compose -A iisc<enter>";
      #     "cz" = ":compose -A zenteiq<enter>";
      #     "cp" = ":compose -A personal<enter>";
      #
      #     # unified inbox
      #     I = ":search tag:inbox<enter>";
      #   };
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

  ########################################
  # SYNC TIMER
  ########################################
  # systemd.user.services.mbsync.Service.ExecStart =
  #   "${pkgs.isync}/bin/mbsync -a && ${pkgs.notmuch}/bin/notmuch new";
  #
  # systemd.user.timers.mbsync = {
  #   Unit.Description = "Timer for mbsync";
  #   Timer = {
  #     OnBootSec = "5m";
  #     OnUnitActiveSec = "10m";
  #   };
  #   Install.WantedBy = [ "timers.target" ];
  # };
}

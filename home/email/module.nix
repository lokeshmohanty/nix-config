{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.email;

  # XOAUTH2 lives in a separate SASL plugin, reached only through this override,
  # which *wraps* mbsync to put cyrus-sasl-xoauth2 on SASL_PATH. A plain isync
  # fails every OAuth account with `selected SASL mechanism(s) not available`,
  # listing every mechanism but the one asked for, out of a configuration that
  # syncs perfectly when mbsync is run by hand.
  mbsync = pkgs.isync.override { withCyrusSaslXoauth2 = true; };
in
{
  # Unconditional: importing the flake's module only declares `programs.ecr`;
  # nothing is installed until it is enabled under `modules.email.enable` below.
  imports = [ inputs.ecr.homeManagerModules.default ];

  options.modules.email.enable = lib.mkEnableOption "email: ecr, and the three binaries it drives";

  config = lib.mkIf cfg.enable {
    # ecr ships none of these and deliberately refuses to, not even behind ours
    # as a fallback: two copies of isync at the same version are not the same
    # binary, and a fallback is one PATH ordering away from being a
    # substitution. These are the ones ecr runs. The systemd user manager
    # carries ~/.nix-profile/bin, so listing them here is what puts them on the
    # server unit's PATH — a user unit inherits nothing from a login shell.
    home.packages = [
      mbsync
      pkgs.msmtp
      pkgs.notmuch
    ];

    programs.ecr = {
      enable = true;
      desktop = true;
    };

    # Their *configuration* is ecr's, through managed mode: `~/.config/ecr/
    # accounts.toml` is the input and ecr renders the isyncrc, the msmtp config,
    # the notmuch config and its hooks under `~/.config/ecr/managed/`. Nothing
    # here writes ~/.config/isyncrc or ~/.config/notmuch any more — a generated
    # file and a home-manager symlink over the same path is one of them being
    # wrong, and ecr's is the one its own IMAP IDLE and `ecr account file` read.
    #
    # accounts.toml is deliberately *not* rendered from Nix: it would be a
    # read-only store symlink, and the client's Accounts tab, `ecr account add`
    # and `ecr account remove` all write it. `ecr account list` reports whether
    # each generated file is current, stale, edited or missing.

    # Contacts and calendars. `ecr account sync-dav` fetches CardDAV and CalDAV
    # into a vdir under ~/.local/state/ecr; the server never schedules it, so
    # the timer is ours. It is read-only — fetching an address book cannot lose
    # anything.
    #
    # It is currently a **no-op**: no account sets `[dav]`, because against
    # Gmail ecr's OAuth token carries no carddav/calendar scope and the preset
    # URL answers 404. The timer is armed for when that works; see
    # docs/decisions.md. vdirsyncer's own vdirs are still on disk, untouched.
    systemd.user.services.ecr-sync-dav = {
      Unit = {
        Description = "Fetch contacts and calendars into ecr's vdir";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe config.programs.ecr.package} account sync-dav";
      };
    };

    systemd.user.timers.ecr-sync-dav = {
      Unit.Description = "Fetch contacts and calendars into ecr's vdir";
      Timer = {
        OnCalendar = "*:0/15";
        # A laptop that was asleep at the quarter hour should still sync when it
        # wakes, rather than waiting for the next one.
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}

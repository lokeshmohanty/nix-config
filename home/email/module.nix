{
  config,
  inputs,
  pkgs,
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
    folders = account.folders or { };

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
    msmtp.extraConfig = {
      auth = "xoauth2";
    };

    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotify = "mbsync ${name}";
      onNotifyPost = ''
        # WARNING: goimapnotify runs this hook through fmt.Sprintf with the mailbox
        # name as the argument, so a literal percent sign here is NOT safe. The
        # first percent-s becomes "INBOX" and every later verb becomes a MISSING
        # marker. That is why the previous printf-based version broke silently: the
        # count came from a printf whose format had been replaced by "INBOX"
        # (so it always counted 1), and the body printf died on the MISSING marker,
        # leaving an empty notification body. Use echo, never printf format verbs.
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/imapnotify"
        ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
        log="$state_dir/${name}.log"
        if [ -f "$log" ] && [ "$(${pkgs.coreutils}/bin/wc -l < "$log")" -gt 2000 ]; then
          ${pkgs.coreutils}/bin/tail -n 500 "$log" > "$log.tmp" && ${pkgs.coreutils}/bin/mv "$log.tmp" "$log"
        fi
        # goimapnotify only forwards the hook's stdout to the journal, so failures
        # in here are otherwise invisible. Keep a bounded per-account stderr log.
        exec 2>>"$log"
        # The trailing percent-s is the one deliberate format verb in this script:
        # it consumes goimapnotify's Sprintf argument (so the mailbox name is
        # logged instead of an EXTRA marker being appended as a bogus last line).
        echo "=== $(${pkgs.coreutils}/bin/date -Iseconds) ${name} mailbox=%s" >&2

        # `notmuch new` runs the postNew hook, which strips the `new` tag before
        # it returns, so `tag:new` is always empty here. Diff this account's
        # inbox message IDs before vs. after indexing to find genuinely new mail.
        before_file=$(${pkgs.coreutils}/bin/mktemp)
        after_file=$(${pkgs.coreutils}/bin/mktemp)
        new_file=$(${pkgs.coreutils}/bin/mktemp)
        ${pkgs.notmuch}/bin/notmuch search --output=messages "tag:inbox and tag:${name}" > "$before_file"
        ${pkgs.notmuch}/bin/notmuch new
        # preNew may have moved deleted messages into Trash; push those moves
        # (and pull anything new) to the server. Run in the background so it
        # does not block the new-mail notification below.
        ${pkgs.isync}/bin/mbsync -a &
        ${pkgs.notmuch}/bin/notmuch search --sort=newest-first --output=messages "tag:inbox and tag:${name}" > "$after_file"
        # FILENAME==ARGV[1] rather than NR==FNR: when "before" is empty (first run,
        # or a failed search) NR==FNR would silently swallow the first "after" line.
        ${pkgs.gawk}/bin/awk 'FILENAME==ARGV[1] {seen[$0]=1; next} !($0 in seen)' "$before_file" "$after_file" > "$new_file"
        ${pkgs.coreutils}/bin/rm -f "$before_file" "$after_file"
        count=$(${pkgs.gawk}/bin/awk 'NF{c++} END{print c+0}' "$new_file")
        echo "count=$count ids=$(${pkgs.coreutils}/bin/tr '\n' ' ' < "$new_file")" >&2
        if [ "$count" -gt 0 ]; then
          # noctalia's NotificationService (Services/System/NotificationService.qml
          # processNotificationText) escapes plain text itself and only preserves
          # <b>/<i>/<u>/<a>/<br> tags; the body is Text.StyledText, which collapses
          # bare newlines. So emit raw "author: subject" and join with <br/>:
          # pre-escaping would double-escape to &amp;amp;, and a bare newline would
          # render as a single collapsed line with no visible subject lines.
          details=""
          n=0
          # Read from a file, not a pipeline: a `... | while` loop runs in a
          # subshell, so anything it fails to emit is lost with no trace.
          while IFS= read -r mid; do
            [ -n "$mid" ] || continue
            [ "$n" -ge 3 ] && break
            # Re-quote the message ID. `notmuch search --output=messages` emits it
            # raw, and IDs containing characters the query parser treats specially
            # (braces, parens, quotes, wildcards) otherwise get parsed as query
            # syntax — which silently matches the WRONG message rather than
            # failing, so the guard below cannot catch it. Verified with
            # id:...{17cd4d3f-...}@intensemail.no-ip.org.
            query="id:\"''${mid#id:}\""
            line=$(${pkgs.notmuch}/bin/notmuch search --format=json "$query" | ${pkgs.jq}/bin/jq -r '.[0] | ( ((.authors // "Unknown") | split("|")[0] | gsub("^\\s+|\\s+$";"")) + ": " + (.subject // "(no subject)") )' 2>&1)
            case "$line" in
              "" | jq:* | null*)
                echo "lookup failed for $mid -> $line" >&2
                ${pkgs.notmuch}/bin/notmuch search --format=json "$query" >&2
                line="(sender/subject unavailable)"
                ;;
            esac
            if [ -n "$details" ]; then
              details="$details<br/>-----------<br/>$line"
            else
              details="$line"
            fi
            n=$((n + 1))
          done < "$new_file"
          echo "details=$details" >&2
          ${pkgs.libnotify}/bin/notify-send -a "mail" "(${name}) $count new" "$details"
        fi
        ${pkgs.coreutils}/bin/rm -f "$new_file"
      '';
      extraConfig = {
        xoAuth2 = true;
      };
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
  # Unconditional: importing the flake's module only declares `programs.ecr`;
  # nothing is installed until it is enabled under `modules.email.enable` below.
  imports = [ inputs.ecr.homeManagerModules.default ];

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
        w3m-full
      ];

      # ecr is a UI over the notmuch maildir this module builds — mbsync fetches
      # into it, msmtp sends from it, notmuch indexes it — so it rides along
      # wherever email is enabled. The server stays opt-in per host (only
      # sudarshan runs it); see hosts/sudarshan/default.nix.
      programs.ecr = {
        enable = true;
        desktop = true;
      };

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
        # ecr's mailing-list sidebar searches `List:<value>`, which needs
        # `List-Id` indexed. notmuch only applies `index.header` to mail
        # indexed after the setting is added, so a database that already has
        # mail needs `notmuch reindex '*'` once for it to take effect.
        extraConfig.index."header.List" = "List-Id";
        new.tags = [
          "new"
          "unread"
        ];
        search.excludeTags = [
          "deleted"
          "spam"
          "trash"
        ];
        hooks.preNew = ''
          # Move every message tagged `deleted` into its account's Trash folder
          # so mbsync propagates the deletion to the server. notmuch's
          # synchronize_flags maps only D/F/P/R/S (not `deleted`/`trash`), so a
          # notmuch tag alone never becomes an IMAP \Deleted — the only reliable
          # way to delete via IMAP (Gmail/Outlook use folder-based trash) is to
          # physically move the file into the Trash maildir. Running this in
          # preNew means `notmuch new` indexes the files at their new path and
          # the postNew trash-folder rule re-tags them in the same cycle.
          mail_root="${config.xdg.dataHome}/Mail"
          moved=0
          ${lib.concatStringsSep "\n" (
            map (account: ''
              trash_dir="$mail_root/${account.name}/${account.folders.trash}/cur"
              ${pkgs.coreutils}/bin/mkdir -p "$trash_dir"
              while IFS= read -r file; do
                [ -z "$file" ] && continue
                case "$file" in
                  *"${account.name}/${account.folders.trash}/"*) continue ;;
                esac
                ${pkgs.coreutils}/bin/mv -n "$file" "$trash_dir/" && moved=$((moved + 1))
              done < <(${pkgs.notmuch}/bin/notmuch search --output=files \
                "tag:deleted and path:${account.name}/** and not path:\"${account.name}/${account.folders.trash}/cur\"")
            '') emailAccounts
          )}
          if [ "$moved" -gt 0 ]; then
            echo "preNew: moved $moved deleted message(s) to Trash" >&2
          fi
        '';
        hooks.postNew = ''
          notmuch tag --batch <<EOM
          ${lib.concatStringsSep "\n" (
            map (account: "+${account.name} -- tag:new and (${accountTagQuery account})") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (
              account: "+inbox -- tag:new and path:\"${account.name}/${account.folders.inbox}/cur\""
            ) emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (
              account: "+sent -inbox -unread -- tag:new and path:\"${account.name}/${account.folders.sent}/cur\""
            ) emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (account: "+sent -inbox -unread -- tag:new and from:${account.address}") emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (
              account:
              "+draft -inbox -unread -- tag:new and path:\"${account.name}/${account.folders.drafts}/cur\""
            ) emailAccounts
          )}
          ${lib.concatStringsSep "\n" (
            map (
              account:
              "+trash +deleted -inbox -unread -- tag:new and path:\"${account.name}/${account.folders.trash}/cur\""
            ) emailAccounts
          )}
          -new -- tag:new
          EOM
        '';
      };

      # imapnotify runs each account's passwordCommand itself, and that is now
      # `ecr oauth token <name>`, so ecr has to be on this unit's PATH — a user
      # unit inherits nothing from the login shell.
      services.imapnotify.enable = true;
      services.imapnotify.path = [
        config.programs.ecr.package
        pkgs.libnotify
      ];

      services.vdirsyncer = {
        enable = true;
        frequency = "*:0/15";
      };
    })
  ];
}

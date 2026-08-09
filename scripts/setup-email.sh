#!/usr/bin/env bash
set -euo pipefail

# Bootstraps mail on a fresh machine. ecr owns the configuration now: it renders
# the isyncrc, the msmtp config, the notmuch config and its hooks from
# ~/.config/ecr/accounts.toml. Nothing here writes those files by hand, and
# `notmuch setup` in particular must not be run — it would write
# ~/.config/notmuch, which is the config ecr is deliberately not using.

echo "== OAuth setup =="

for acc in main zenteiq personal; do
  echo "run: ecr oauth setup $acc --provider gmail --email <address>"
done
echo "run: ecr oauth setup iisc --provider microsoft --email <address>"

echo "== Accounts =="

if [ ! -f "$HOME/.config/ecr/accounts.toml" ]; then
  echo "no accounts.toml — add each account, then rerun:"
  echo "  ecr account add main --address <address> --provider gmail"
  echo "or, if this machine already has a working mbsync/msmtp/notmuch setup:"
  echo "  ecr account import        # shows what ecr would generate"
  echo "  ecr account import --write"
  exit 1
fi

# Renders the four managed files. Safe to rerun: a file you edited by hand is
# moved aside rather than overwritten.
ecr account apply

echo "== Check =="
ecr doctor

echo "== Initial sync =="
mbsync -a || true
ecr notmuch new

echo "== Contacts and calendars =="
# Fetches CardDAV and CalDAV into a vdir under ~/.local/state/ecr. Read-only.
# The ecr-sync-dav.timer keeps it fresh from here on.
ecr account sync-dav || true

echo "== Done =="

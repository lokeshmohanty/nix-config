#!/usr/bin/env bash
set -euo pipefail

maybe_discover() {
  local pair="$1"
  local local_path="$2"

  if ! find "$local_path" -mindepth 1 -maxdepth 1 -type d | read -r _; then
    vdirsyncer discover "$pair"
  fi
}

echo "== OAuth setup =="

for acc in main iisc zenteiq personal; do
  echo "run oauthman setup $acc --email <address> before syncing"
done

echo "== Maildir scaffold =="
for acc in main zenteiq personal iisc; do
  for folder in Sent Drafts Trash; do
    mkdir -p "$HOME/.local/share/Mail/$acc/$folder"
  done
done

echo "== Initial sync =="
mbsync -a || true

echo "== Notmuch setup =="

notmuch setup <<EOF
$HOME/Mail
Lokesh Mohanty
lokesh1197@gmail.com
EOF

notmuch new

echo "== Done =="

echo "== DAV bootstrap =="
maybe_discover contacts_main "$HOME/.local/share/contacts/main"
maybe_discover contacts_personal "$HOME/.local/share/contacts/personal"
maybe_discover contacts_zenteiq "$HOME/.local/share/contacts/zenteiq"
maybe_discover calendar_main "$HOME/.local/share/calendars/main"
maybe_discover calendar_personal "$HOME/.local/share/calendars/personal"
maybe_discover calendar_zenteiq "$HOME/.local/share/calendars/zenteiq"

echo "== DAV sync =="
vdirsyncer sync

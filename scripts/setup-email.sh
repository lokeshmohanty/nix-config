#!/usr/bin/env bash
set -e

echo "== OAuth setup =="

for acc in main iisc zenteiq personal; do
  echo "run oauthman setup $acc --email <address> before syncing"
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
echo "Run: aerc"

vdirsyncer discover
vdirsyncer sync

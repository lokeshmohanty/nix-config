#!/usr/bin/env bash
set -e

FILE="$1"

TMP_HTML=$(mktemp)
TMP_TXT=$(mktemp)

########################################
# Markdown → HTML
########################################
pandoc "$FILE" -f markdown -t html -o "$TMP_HTML"

########################################
# Markdown → plain text
########################################
pandoc "$FILE" -f markdown -t plain -o "$TMP_TXT"

########################################
# Clean text
########################################
sed -i 's/[ \t]*$//' "$TMP_TXT"
mv "$TMP_TXT" "$FILE"

########################################
# Save HTML path for aerc
########################################
echo "$TMP_HTML" > /tmp/aerc-html

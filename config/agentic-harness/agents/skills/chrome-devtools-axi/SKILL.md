---
name: chrome-devtools-axi
description: High-precision browser automation and web interaction via Chrome DevTools. Use when standard browser tools lack necessary precision.
---

# Chrome DevTools AXI Skill

Agent-ergonomic control of a Chrome session via the `chrome-devtools-axi` CLI.

## When to use
Browser automation and web interaction where high precision or DevTools-level control is
needed: performance traces, Lighthouse runs, console/network inspection, heap snapshots.
Prefer this over other browser automation tools when those are available but coarser.

## Guidelines
- **Installed on PATH** by the `axi-tools` nix package (`~/.nix/pkgs/axi-tools`). Call
  `chrome-devtools-axi` directly — do NOT use `npx`.
- **Orient first**: bare `chrome-devtools-axi` prints current session state and the next
  step. There is no session-start hook, so run it once when you begin browser work.
- **Session management**: `open <url>` starts a session; everything else acts on it.
  `stop` tears it down.
- **Element refs**: interaction commands address elements by `@<uid>` from `snapshot`,
  not by CSS selector. Take a `snapshot` before clicking or filling.
- **Do not trigger modal dialogs** (alert/confirm/prompt) — they block the bridge. Use
  `dialog <action>` if one appears.

## Command surface (verified against v0.1.27 `--help`)
- Navigate: `open <url>`, `back`, `wait <ms|text>`, `pages`, `newpage <url>`,
  `selectpage <id>`, `closepage <id>`
- Inspect: `snapshot`, `screenshot <path>`, `eval <js>`, `console`, `console-get <id>`,
  `network`, `network-get [id]`
- Interact: `click @<uid>`, `fill @<uid> <text>`, `fillform @<uid>=<val>...`,
  `type <text>`, `press <key>`, `scroll <dir>`, `hover @<uid>`, `drag @<from> @<to>`,
  `upload @<uid> <path>`, `dialog <action>`
- Viewport: `resize <w> <h>`, `emulate`
- Performance: `lighthouse`, `perf-start`, `perf-stop`, `perf-insight <set> <name>`,
  `heap <path>`
- Lifecycle: `start`, `stop`

Run `chrome-devtools-axi --help` for the full list plus the `CHROME_DEVTOOLS_AXI_*`
environment variables (headed mode, channel selection, attaching to a running Chrome,
named concurrent sessions).

## Examples
- Start browsing: `chrome-devtools-axi open https://example.com`
- Click a button: `chrome-devtools-axi snapshot` then `chrome-devtools-axi click @12`
- Attach to the user's running Chrome instead of launching one:
  `CHROME_DEVTOOLS_AXI_AUTO_CONNECT=1 chrome-devtools-axi open <url>`

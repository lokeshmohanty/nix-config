# Decisions

## 2026-08-02 — No `printf` format verbs in imapnotify hooks (goimapnotify Sprintf)

Mail notifications showed a count but an empty body, and the count was always
wrong. Root cause is upstream of both notmuch and the notification daemon:
**goimapnotify passes the hook command through `fmt.Sprintf` with the mailbox
name as the argument** before handing it to bash. In `home/email/module.nix`
`onNotifyPost` this meant the *first* `%s` in the script — the one in
`printf '%s\n' "$newids"` that fed the `count` pipeline — was replaced by the
literal `INBOX`, so the count was computed from `printf 'INBOX\n'` and was
always `1`. Every later verb became `%!s(MISSING)`, so the body `printf`
aborted with ``printf: `!': invalid format character`` and emitted nothing.
Confirmed by running `fmt.Sprintf(hook, "INBOX")` over the deployed
`~/.config/imapnotify/imapnotify-main-config.json`.

**Rule: hook bodies use `echo`, never `printf` with format verbs.** One
deliberate `%s` is kept in the opening log line so it absorbs Sprintf's
argument; without a verb, Go appends `%!(EXTRA string=INBOX)` as a bogus
trailing line.

Two further defects fixed in the same hook: message IDs from
`notmuch search --output=messages` are now re-quoted as `id:"…"` — IDs
containing query-syntax characters (e.g. `…{17cd4d3f-…}@intensemail.no-ip.org`)
were parsed as query operators and silently matched the *wrong* message rather
than erroring, so no guard could catch it; and the before/after dedup `awk`
switched from `NR==FNR` to `FILENAME==ARGV[1]`, which otherwise drops the first
new message whenever the "before" snapshot is empty.

goimapnotify forwards only the hook's **stdout** to the journal, which is why
all of this failed invisibly. Hooks now append stderr to a bounded (2000-line)
per-account log at `~/.local/state/imapnotify/<account>.log`.

This supersedes the diagnosis in the entry below: the toast line cap was a real
and separate constraint, but the empty bodies were this Sprintf bug.

## 2026-08-02 — Patch noctalia-shell toast line cap; translucent notifications

Mail notifications from `home/email/module.nix` `onNotifyPost` were elided:
noctalia-shell (the quickshell-based notification daemon) hardcodes the toast
body to `maximumLineCount: 5` in `Modules/Notification/Notification.qml`, and
the multi-message body (one `author: subject` line per new mail, separated by
`<br/>-----------<br/>`) exceeded five lines so the tail was cut with
`Text.ElideRight`. The cap is not exposed in noctalia's settings UI, so it is
patched in-tree rather than configured at runtime.

`system/desktop-environment/noctalia.nix` now builds
`inputs.noctalia.packages.<system>.default` through `overrideAttrs` with a
`postFixup` `sed` that rewrites the body element's `maximumLineCount: 5` to
`20` (anchored to the leading-space + `5$` so it hits only line 689, not the
summary/compact caps of 3/1/2). Verified by realising the derivation: the
built `Notification.qml` differs from the upstream output on exactly that one
line. Translucency needed no patch — `notifications.backgroundOpacity` is a
runtime setting read by the card's `Qt.alpha(Color.mSurface, ...)`, so
`config/noctalia/settings.json` sets it to `0.7` (70%); the symlinked
`~/.config/noctalia` dir makes that live without a rebuild.

The `overrideAttrs` adds a derivation to the system closure (120 derivations
in a `dry-build`), so the line-cap change takes effect only after
`nixos-rebuild switch`; the opacity change is immediate on quickshell restart.

## 2026-07-31 — SearXNG backs pi `web_search` (self-hosted, no API keys)

pi's web search comes from the `pi-web-access` package, not pi core. It has
no native DuckDuckGo provider (v0.17.0 supports openai, brave, parallel,
tinyfish, search1api, searchinfinity, querit, tavily, serpdive, anysearch,
searxng, exa, perplexity, gemini). The previous default was AnySearch, a
shared third-party API that was slow and rate-limited. SearXNG is a
self-hostable meta-engine, so we run a localhost-only instance and point
pi-web-access at it — no API keys, no shared rate limits.

`system/searxng.nix` runs a localhost-only SearXNG instance
(`services.searx`, built-in HTTP server, no uwsgi/nginx/redis) bound to
`127.0.0.1:8888`. SearXNG's loader requires `use_default_settings.engines`
to be a dict of `keep_only`/`remove`, not a boolean (a bool crashes
`update_settings` with `'bool' object has no attribute 'get'`); engine names
are lowercase and the `engines` override merges into the kept default by
name. The engine set is **Bing only**: measured 2026-08-02 on sudarshan,
this host's IP is reputation-flagged by the other no-API-key engines —
DuckDuckGo's html/lite endpoints return a CAPTCHA
(`SearxEngineCaptchaException`), Brave returns HTTP 429, Mojeek and Qwant
return HTTP 403/access-denied — while Bing (`www.bing.com/search`) returns
7-10 clean results per query reliably. SearXNG ships bing disabled by
default, so it is enabled explicitly. `config/agentic-harness/pi/web-search.json`
sets `provider: "searxng"` + `searxngBaseUrl: "http://127.0.0.1:8888"`.
Enabled on all three NixOS hosts (`searxng.enable`) since all run pi; the
server home profile does not import `system/`.

Two correctness details: (1) pi-web-access's SSRF guard always blocks the
literal hostname `localhost` but allows `127.0.0.1` when `127.0.0.0/8` is in
`ssrf.allowRanges`, so the URL uses the IP, not the name. (2) pi-web-access reads
`web-search.json` from `$XDG_CONFIG_HOME/pi` (set to `~/.config` by home-manager),
NOT from `~/.pi`, so the repo-tracked file was shadowed by an unmanaged
`~/.config/pi/web-search.json` written by the curator UI. `home/activations.nix`
now symlinks `~/.config/pi/web-search.json` to the repo file so the repo is the
single source of truth. `allowBrowserCookies`/`chromeProfile` are kept (they
govern Gemini Web, a separate capability) and `searchRouting` with anysearch is
dropped. `web-search.json` also sets `workflow: "none"`: pi-web-access's
default workflow is `summary-review`, which auto-opens an interactive browser
curator and blocks at a `waiting-for-approval` phase — `none` makes
`web_search` a plain tool that returns results directly (the agent then
summarizes/acts), matching headless `pi -p` (which already defaults to `none`
because `!hasUI`).

## 2026-07-29 — kitty replaces foot as the default terminal

The niri session spawns a hidden kitty server at startup
(`kitty --single-instance --start-as=hidden`) and every launcher — `Mod+Return`,
`Mod+M`, the waybar `cpu`/`memory` click actions — uses `kitty --single-instance`,
which is served by that instance and returns immediately. This is the same
client/server shape the previous `foot --server` + `footclient` pair had, so
window environments are still inherited from the session at login, frozen there.

The driver is graphics. Both terminals implement the kitty graphics protocol, but
measured on this machine (kitty 0.46.2 vs ghostty 1.3.1, identical escape bytes,
three runs each): ghostty silently dropped one Unicode-placeholder placement in
two of three runs when direct placements and placeholder placements were mixed in
one stream — which is exactly what pi's `rich-renderer` emits (display math
direct, inline math via placeholders). `q=2` suppresses the error response, so a
dropped formula is invisible. kitty rendered all cases in three of three runs.
kitty also has `kitten @` remote control, already wired through
`allow_remote_control` + `listen_on` in `home/terminal/kitty.nix`, which ghostty
has no equivalent for; the agent harness can drive it.

`modules.gui.foot.enable` now defaults to false rather than being removed, so foot
is one line away if kitty misbehaves under niri. TERM stays kitty's default
`xterm-kitty`: pi detects image support from it, and `kitten ssh` handles terminfo
on remote hosts.

## 2026-07-21 — Narrow first Ubuntu installer contract

The first non-NixOS installer offers two explicit modes. Nix mode supports
Ubuntu on x86_64, with systemd required when Nix must be installed; it passes the
validated login user, home, and checkout path to `lokesh@server` during impure
evaluation. APT mode supports Ubuntu without adding the flake's architecture
restriction and installs only packages available from configured Ubuntu
repositories. Normal pure flake evaluation retains the existing `lokesh`
defaults.

The installer preserves an existing Nix installation and uses the Home Manager
package pinned by this repository. Existing checkouts must be clean and are only
fast-forwarded. This makes reruns predictable and avoids destructive recovery
behavior such as resetting or stashing. APT-mode config collisions are preserved
in a logged, timestamped backup tree before managed links replace them.

APT mode deliberately provides reduced equivalence. Home Manager-generated
settings, Nix-only AI tools, custom packages, and the wrapped Neovim dependency
closure are not replaced with unpinned third-party installers.

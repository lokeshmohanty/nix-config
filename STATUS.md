# STATUS — volatile state

*Update in place; keep short; absolute dates. History lives in git log.*

## Current focus (2026-08-02)

- pi `web_search` now backs onto a localhost-only SearXNG
  (`system/searxng.nix`, Bing-only at `127.0.0.1:8888`) instead of
  AnySearch: self-hosted, no API keys, no shared rate limits. `workflow:
  "none"` makes `web_search` a plain tool (no curator browser, no approval)
  that returns results directly for the agent to summarize/act on. See
  `docs/decisions.md`.

## Pending chores

- [ ] Fix deprecation: `programs.sioyek.config.startup_commands` should be a list
  of strings (warns on every home-manager switch).
- [ ] `home-manager news` backlog (378 unread as of 2026-07-18).
- [ ] pi `models.json` has hardcoded vllm endpoints (localhost + 10.169.20.x) —
  not portable across hosts; consider per-host vars.
- [ ] Delete `~/.harness-backup-2026-07-18/` once harness v2 is proven stable.
- [x] Commit the searxng / pi-web-search change after a successful rebuild +
  switch on sudarshan.

## Open obligations / blockers

- (none)

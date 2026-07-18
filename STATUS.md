# STATUS — volatile state

*Update in place; keep short; absolute dates. History lives in git log.*

## Current focus (2026-07-18)

- Agentic-harness v2 live (AGENTS.md-first, all harnesses incl. antigravity wired;
  see `config/agentic-harness/agents/docs/`). Harness-global volatile state:
  `config/agentic-harness/agents/STATUS.md`.

## Pending chores

- [ ] Fix deprecation: `programs.sioyek.config.startup_commands` should be a list
  of strings (warns on every home-manager switch).
- [ ] `home-manager news` backlog (378 unread as of 2026-07-18).
- [ ] pi `models.json` has hardcoded vllm endpoints (localhost + 10.169.20.x) —
  not portable across hosts; consider per-host vars.
- [ ] Delete `~/.harness-backup-2026-07-18/` once harness v2 is proven stable.

## Open obligations / blockers

- (none)

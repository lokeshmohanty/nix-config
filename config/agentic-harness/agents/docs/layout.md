# Harness Layout — where everything lives

*Purpose: the single source of truth for the file layout and symlink map. Last verified: 2026-07-18.*

## Canonical tree (git-tracked in `~/.nix`)

```
~/.nix/config/agentic-harness/
├── agents/                  # = ~/.agents (whole-dir symlink)
│   ├── AGENTS.md            # global index — the ONLY always-loaded global context
│   ├── PREFERENCES.md       # who Lokesh is; environment & tooling preferences
│   ├── STATUS.md            # global volatile state
│   ├── docs/                # THIS documentation
│   └── skills/              # global skills (each: SKILL.md [+ memory/ + references/])
├── claude/                  # nix-managed pieces of ~/.claude (selective links, see below)
│   ├── CLAUDE.md -> ../agents/AGENTS.md
│   ├── settings.json        # model, plugins, global hooks
│   └── rules/               # global rule files (context7)
├── pi/                      # nix-managed pieces of ~/.pi
│   ├── agent/{settings.json, models.json}
│   └── web-search.json
├── templates/project/       # scaffolding source for harness-init
├── bin/                     # harness-init, harness-session-start, docs-nudge
└── README.md
```

## Symlink map (created by `~/.nix/home/activations.nix`, `ln -sfn`)

| Link | Target | Note |
|---|---|---|
| `~/.agents` | `…/agentic-harness/agents` | whole dir — safe, no runtime writes besides ours |
| `~/.claude/CLAUDE.md` | `~/.agents/AGENTS.md` | `~/.claude` itself stays a REAL dir (runtime state: projects/, sessions/, credentials) |
| `~/.claude/skills` | `~/.agents/skills` | |
| `~/.claude/settings.json` | `…/agentic-harness/claude/settings.json` | secrets never go here |
| `~/.claude/rules` | `…/agentic-harness/claude/rules` | |
| `~/.pi/web-search.json` | `…/agentic-harness/pi/web-search.json` | `~/.pi` stays a REAL dir (sessions, auth, trust) |
| `~/.pi/agent/settings.json` | `…/agentic-harness/pi/agent/settings.json` | runtime updates land in nix repo — intended |
| `~/.pi/agent/models.json` | `…/agentic-harness/pi/agent/models.json` | |
| `~/.pi/agent/APPEND_SYSTEM.md` | `~/.agents/AGENTS.md` | |
| `~/.pi/agent/skills` | `~/.agents/skills` | |
| `~/.codex/AGENTS.md` | `~/.agents/AGENTS.md` | `~/.codex/config.toml` is machine-local (secrets, trust) — NOT nix-managed |
| `~/.codex/skills` | `~/.agents/skills` | |
| `~/.gemini/AGENTS.md` | `~/.agents/AGENTS.md` | |

**Never** whole-dir-symlink `~/.claude`, `~/.pi`, or `~/.codex` into the nix repo:
they hold credentials and runtime state. Selective links only. Use `ln -sfn`
(never bare `ln -sf` on an existing directory — it drops the link *inside* it).

## Per-project layout (see project-template.md)

```
<repo>/
├── AGENTS.md            # small index (tracked); CLAUDE.md -> AGENTS.md (tracked symlink)
├── STATUS.md            # volatile state (tracked)
├── docs/                # full project documentation (tracked) — see docs-sync skill
├── .agents/
│   └── skills/<skill>/{SKILL.md, memory/}   # tracked
├── .claude -> .agents   # tracked symlink; harness-local runtime files are gitignored
└── .gitignore           # includes harness runtime ignores (template)
```

Scaffolded automatically by the Claude SessionStart hook (`harness-session-start`)
in any unharnessed git repo, or manually via `harness-init [dir]`.

## Editing discipline

- Global harness change → edit under `~/.nix/config/agentic-harness/` (directly or
  through the `~/.agents` symlink), then **commit `~/.nix`**.
- Machine-local / secret state → live files only: `~/.claude/settings.local.json`,
  `~/.claude/.credentials.json`, `~/.codex/config.toml`, `~/.pi/agent/auth.json`.
- Per-repo agent permissions → `<repo>/.claude/settings.local.json` (not committed).
- After changing `activations.nix`: run `home-manager switch` (or apply the same
  `ln -sfn` commands manually — they are idempotent).

# Harness Layout — where everything lives

*Purpose: the single source of truth for the file layout and symlink map. Last verified: 2026-07-24.*

> **Correction (2026-07-24):** the live symlink model is **whole-dir**, not the
> "selective links" earlier revisions described. `~/.claude`, `~/.pi`, `~/.codex`,
> `~/.gemini` are each a single symlink into the nix repo; what is *tracked* vs
> runtime is controlled by a `.gitignore` inside each tool dir (e.g.
> `claude/.gitignore`, `pi/.gitignore`). Credentials/session/cache files therefore
> physically live under `~/.nix/config/agentic-harness/<tool>/` but are gitignored.
> Inner cross-tool links (skills, agents) are committed *relative* symlinks.

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
├── bin/                     # harness-init, harness-session-start, docs-nudge, screen-rec
└── README.md
```

## Symlink map

Two layers:

**A. Whole-dir links** (created by `~/.nix/home/activations.nix`, `ln -sfn`):

| Link | Target |
|---|---|
| `~/.agents` | `…/agentic-harness/agents` |
| `~/.claude` | `…/agentic-harness/claude` |
| `~/.pi` | `…/agentic-harness/pi` |
| `~/.codex` | `…/agentic-harness/codex` |
| `~/.gemini` | `…/agentic-harness/gemini` |
| `~/.local/bin/<harness bins>` | `…/agentic-harness/bin/*` |

What is *tracked* inside each tool dir is decided by that dir's `.gitignore`
(runtime state — credentials, sessions, cache, projects — is gitignored but
physically present). `AGENTS.md` context files are committed symlinks to
`../agents/AGENTS.md` (Claude: `claude/CLAUDE.md`; codex/gemini analogous;
gemini's is `GEMINI.md` by convention).

**B. Inner cross-tool links** — committed *relative* symlinks that make the
shared `agents/{skills,agents}` visible to each harness (resolve automatically
via the whole-dir link; no activation step needed):

| Link (in repo) | Target | Consumed by |
|---|---|---|
| `claude/skills` | `../agents/skills` | Claude Code global skills |
| `claude/agents` | `../agents/agents` | Claude Code global subagent fleet |
| `pi/agent/skills` | `../../agents/skills` | pi skills (@tintinweb/pi-subagents) |
| `pi/agent/agents` | `../../agents/agents` | pi global subagent fleet |

`bin/harness-heal` recreates any of these if a whole-dir operation drops them,
without rewriting good links (no churn). See [delegation.md](delegation.md).

Use `ln -sfn`, never bare `ln -sf` on an existing directory — it drops the link
*inside* it. Never commit secrets: they stay gitignored inside the tool dirs, or
in machine-local files (`~/.codex/config.toml`, `pi/agent/auth.json`).

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

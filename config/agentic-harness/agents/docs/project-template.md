# Project Template — what every repo must have

*Purpose: the contract `harness-init` scaffolds and audits against. Last verified: 2026-07-18.*

Source files: `~/.nix/config/agentic-harness/templates/project/`.

| Item | Role | Tracked? |
|---|---|---|
| `AGENTS.md` | Small index: what the project is, map to STATUS/docs/skills, binding rules. Keep under ~60 lines. | yes |
| `CLAUDE.md → AGENTS.md` | Compatibility symlink for Claude Code. | yes (as symlink) |
| `STATUS.md` | Volatile state: current focus, next actions, open obligations. Updated in place. | yes |
| `docs/` | Full project documentation, plain markdown (see `docs-sync` skill for structure). | yes |
| `.agents/skills/` | Project skills, each `SKILL.md` + optional `memory/`. | yes |
| `.claude → .agents` | Compatibility symlink. | yes (as symlink) |
| `.gitignore` additions | Ignore harness runtime: `.claude/settings.local.json`, `.agents/*.lock`, `.gitnexus/`, `graphify-out/`. | yes |

Division of knowledge (never duplicate, always link):
- **docs/** — what the project *is* and how to use/change it (for any LLM, incl. pi).
- **skills + memory/** — how to *work on* it well (procedures, traps, decisions agents need mid-task).
- **STATUS.md** — what is true *right now*.
- **AGENTS.md** — the index over all of the above.

Scaffolding: the Claude SessionStart hook (`harness-session-start`) creates missing
pieces in any git repo that has none of them (it never overwrites existing files and
skips non-git dirs and throwaway dirs like /tmp). Manual: `harness-init [dir]`.
Existing repos with their own conventions (e.g., a rich CLAUDE.md): convert by making
AGENTS.md canonical and symlinking CLAUDE.md to it — content wins, names are fixed.

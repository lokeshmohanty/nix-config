# Harness Documentation — Index

*Reference for any agent working on or with Lokesh's agent harness. Last synced: 2026-07-18.*

The harness is **AGENTS.md-first**: every harness (Claude Code, pi, Codex, Gemini)
reads the same files; `CLAUDE.md` and `.claude` are compatibility symlinks. Canonical
config lives in `~/.nix/config/agentic-harness/` and is committed in the `~/.nix` repo.

| Page | Read when |
|---|---|
| [layout.md](layout.md) | You need to know where anything lives (global + per-project), the symlink map, or the .gitignore rules. |
| [harnesses.md](harnesses.md) | You need to know what a specific harness supports (hooks, skills, extensions, MCP, config paths) before using or extending it. |
| [hooks.md](hooks.md) | You are adding/changing a hook, or wondering why one fires. Current hook inventory. |
| [tools.md](tools.md) | You need GitNexus, gortex, context7, or wonder which code-intelligence tool applies. |
| [project-template.md](project-template.md) | You are scaffolding or auditing a project's harness (what every repo must have). |

Related skills: `harness-ops` (make changes here), `docs-sync` (project docs/ upkeep).

Rules of this folder:
- Every page starts with purpose + "last verified" date.
- Update the page in the same change as the thing it documents (harness-ops rule).
- Unverifiable claims are marked `VERIFY`, never guessed.

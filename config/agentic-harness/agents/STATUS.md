# Global STATUS — volatile harness state

*Update in place; keep short. History lives in `~/.nix` git log.*

## Current (2026-07-18)

- **Harness v2 rollout (2026-07-18):** restructured — canonical tree at `~/.nix/config/agentic-harness/`, AGENTS.md-first with CLAUDE.md symlinks, docs/-per-project, aggressive plugin prune. See `docs/layout.md`. Pending: `home-manager switch` to re-affirm activation symlinks (they were also applied manually).
- **Graph tools:** gortex scoped to zenteiq code repos only (dsdg, prime-rl, verifiers) via per-repo `.claude/settings.local.json` + `.mcp.json`; global hooks removed. graphify removed. GitNexus used on demand via `npx gitnexus@latest` (docs-sync skill).
- **pi:** local Gemma-4-31B (vllm), reads AGENTS.md + APPEND_SYSTEM.md symlink; use for docs-reading and routine tasks.
- **Backup of pre-v2 state:** `~/.harness-backup-2026-07-18/` (safe to delete once v2 is stable).

## Machines / endpoints

- archimedes — experiment host (thesis runs).
- vllm endpoints for pi: see `~/.pi/agent/models.json` (localhost + 10.169.20.57; not portable).

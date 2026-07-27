# Global STATUS — volatile harness state

*Update in place; keep short. History lives in `~/.nix` git log.*

## Current (2026-07-24)

- **Delegation layer (2026-07-24):** tasks now route to a shared skill-aware
  subagent fleet (`~/.agents/agents/{orchestrator,explorer,implementer,reviewer}.md`),
  read by Claude (`~/.claude/agents`) and pi (`@tintinweb/pi-subagents`). Selector
  `harness-skill-pick` (auto-picks skills+memories) + pi `pick_skills` tool
  (`pi/agent/extensions/pi-harness-delegate/`). `harness-init` scaffolds
  `.agents/agents/`; AGENTS.md carries the protocol. Full: `docs/delegation.md`.
  - **Fixed a live bug:** whole-dir symlinking had dropped `~/.claude/skills`, so
    Claude was loading **zero** global skills. Restored via committed relative
    symlinks (`claude/skills`, `claude/agents`, `pi/agent/agents`) + new
    `bin/harness-heal` (run by the SessionStart hook, churn-free).
  - **TODO smoke tests:** (1) `home-manager switch` to link the new `bin/*`
    (`harness-skill-pick`, `harness-heal`) onto PATH — done live for this session
    only. (2) `pi list` to confirm `pi-harness-delegate` auto-loads and exposes
    `pick_skills`; else `pi -e .../pi-harness-delegate/index.ts` + add to settings.
    (3) In a Claude session, confirm the fleet appears as spawnable agents.
- **Harness v2 rollout (2026-07-18):** restructured — canonical tree at `~/.nix/config/agentic-harness/`, AGENTS.md-first with CLAUDE.md symlinks, docs/-per-project, aggressive plugin prune. See `docs/layout.md`. Pending: `home-manager switch` to re-affirm activation symlinks (they were also applied manually).
- **Graph tools:** gortex scoped to zenteiq code repos only (dsdg, prime-rl, verifiers) via per-repo `.claude/settings.local.json` + `.mcp.json`; global hooks removed. graphify removed. GitNexus used on demand via `npx gitnexus@latest` (docs-sync skill).
- **MCP cleanup (2026-07-27):** `~/.claude.json` global `mcpServers` is now **context7 only**. Removed stale `gitnexus` (dead binary → ENOENT everywhere) and global `gortex` (duplicated the per-repo scoping); added `enabledMcpjsonServers: ["gortex"]` to prime-rl + verifiers so their per-repo `.mcp.json` auto-approves. Backup: `~/.claude.json.bak-2026-07-27`.
- **pi:** local Gemma-4-31B (vllm), reads AGENTS.md + APPEND_SYSTEM.md symlink; use for docs-reading and routine tasks.
- **Backup of pre-v2 state:** `~/.harness-backup-2026-07-18/` (safe to delete once v2 is stable).

## Machines / endpoints

- archimedes — experiment host (thesis runs).
- vllm endpoints for pi: see `~/.pi/agent/models.json` (localhost + 10.169.20.57; not portable).

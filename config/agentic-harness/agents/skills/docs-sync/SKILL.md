---
name: docs-sync
description: >
  Create or refresh a project's docs/ folder so any LLM (including small local
  models via pi) can answer questions and perform tasks from it alone. Use when a
  repo lacks docs/, when the Stop-hook nudge reports docs drift, when asked to
  document a project, or after significant code/architecture changes.
---

# Docs Sync

Goal: `docs/` is the single place an agent reads to understand the project —
plain markdown, no tooling required to consume it.

## Required structure

```
docs/
├── index.md          # entry point: what this project is, map of the rest of docs/
├── architecture.md   # components, data flow, key decisions + WHY (intent!)
├── how-to/           # one file per common task (setup, run, test, deploy, ...)
├── reference/        # generated/structural: API surface, module map, schemas
└── decisions.md      # dated log of significant decisions (append-only)
```

Small projects may collapse this to a single `index.md` — but it must exist and be
honest about what's missing. `index.md` always states when docs were last synced.

## Refresh procedure

1. Read `docs/index.md` (if present), `AGENTS.md`, `STATUS.md`, and `git log --oneline -20`
   to find what changed since the last sync.
2. **Code repos — seed the structural half deterministically:**
   - If the repo is gortex-tracked (zenteiq: dsdg, prime-rl, verifiers): `gortex wiki`
     output feeds `reference/`.
   - Otherwise use GitNexus (no install needed, no LLM cost, local):
     `npx gitnexus@latest analyze` then copy/adapt its generated markdown into
     `docs/reference/`. Do not commit `.gitnexus/` (gitignored by template).
3. Write/update the intent half yourself (architecture.md rationale, how-tos,
   decisions.md) — no tool can generate intent; pull it from the session, STATUS.md,
   commit messages, and skill memories.
4. Verify pi-readability: every page is self-contained markdown, no reliance on
   MCP/graph tools, relative links resolve, no page over ~400 lines.
5. Update the sync date in `index.md`. Commit docs/ with the change that caused it.

## Rules

- docs/ documents the project; skill `memory/` documents how to *work on* it;
  STATUS.md holds volatile state. Don't duplicate across the three — link.
- Generated reference pages must be labeled with their generator and date.
- Never let docs/ silently rot: if you touch tracked source in a session and don't
  update docs/, say so explicitly in your final summary.

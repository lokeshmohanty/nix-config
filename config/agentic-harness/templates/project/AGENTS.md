# PROJECT_NAME — Agent Index

> Minimal index. Read `STATUS.md` next for current state. Full documentation in
> `docs/` (start at `docs/index.md`). Global harness rules: `~/.agents/AGENTS.md`.

## What this is

TODO: one paragraph — purpose, stack, entry points.

## Map

| path | what |
|---|---|
| `STATUS.md` | volatile: current focus, next actions, obligations |
| `docs/` | full documentation — answer questions from here first |
| `.agents/skills/` | project skills + memories (invoke on demand) |

## Project skills & subagents

*(none yet — create skills with the `harness-ops` skill when durable knowledge
accumulates.)* The global delegation protocol applies (`~/.agents/AGENTS.md`):
tasks are handled by the shared subagent fleet, which auto-picks skills/memories
via `harness-skill-pick`. Drop project-specific subagent defs in
`.agents/agents/*.md` to add or override workers for this repo.

## Binding rules

1. Significant changes update `docs/` in the same session (`docs-sync` skill).
2. Durable knowledge → a skill's `memory/`; volatile state → `STATUS.md`; never bloat this file.
3. Summaries in main context; exploration in sub-agents.

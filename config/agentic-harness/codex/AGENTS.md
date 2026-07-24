# Global Agent Harness — Index

> Minimal by design. This file is the only global context loaded into every session.
> Everything else is a pointer — read on demand, never paste back here.
> Canonical source: `~/.nix/config/agentic-harness/agents/` (= `~/.agents`), committed in `~/.nix`.

## Read next (on demand)

- `~/.agents/PREFERENCES.md` — who Lokesh is, environment (NixOS), package-manager and tooling preferences. Read before any environment/dependency/tooling decision.
- `~/.agents/STATUS.md` — global volatile state (machine, models, ongoing harness changes).
- `~/.agents/docs/` — **harness documentation**: layout spec, per-harness feature matrix (claude/pi/codex/gemini), hooks, tools, project template. Query this before creating or modifying any skill, hook, extension, or harness config. Start at `docs/index.md`.

## Per-project layout (every repo follows this)

`AGENTS.md` (small index; `CLAUDE.md` symlinks to it) · `STATUS.md` (volatile state) ·
`docs/` (full project documentation — any LLM answers from here) ·
`.agents/skills/<skill>/SKILL.md` + `memory/` (durable knowledge; `.claude` symlinks to `.agents`).
Missing pieces are scaffolded by the session-start hook or `harness-init`.

## Global skills (invoke on demand)

- `harness-ops` — create/modify skills, memories, hooks, harness config; skill-writing standards. **Use for any harness change.**
- `docs-sync` — create/refresh a project's `docs/` folder (seeds code repos with GitNexus).
- `context-manager` — recursive delegation + model routing for large tasks.
- `test-driven-development`, `systematic-debugging`, `verification-before-completion` — process discipline for code work.
- `no-mistakes` — local validation pipeline (tests, lint, push, PR, CI).
- `axi` (+ `gh-axi`, `chrome-devtools-axi`, `lavish-axi`) — agent-facing CLI standards and tools.
- `context7-mcp` — current library/framework docs.

## Binding rules

1. Main context stays an index: summaries return, exploration goes to sub-agents.
2. Durable knowledge → a skill's `memory/`; volatile state → `STATUS.md`; documentation → `docs/`. Never bloat AGENTS.md.
3. Significant code/architecture changes update the project's `docs/` in the same session.
4. 100% accuracy from verified sources; mark `VERIFY` and escalate rather than invent.
5. Project-level AGENTS.md overrides this file inside its repo.

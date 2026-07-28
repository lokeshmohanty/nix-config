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

## Delegation protocol (default for any non-trivial task)

Assigned tasks are handled by **subagents**, not the main context. The main
context is an orchestrator: it scopes the task, delegates, and synthesises.

- **Pick knowledge first.** Before acting or delegating, discover which skills
  and memories apply: run `harness-skill-pick "<keywords>"` (Claude: via Bash;
  pi: the `pick_skills` tool). It lists matching global + project skills and
  their `memory/` files. Load those `SKILL.md`s and read the memories — never
  re-derive what a skill/memory already records.
- **Delegate to the fleet** (`~/.agents/agents/`, read by both Claude Code and
  pi via `@tintinweb/pi-subagents`): `orchestrator` (decompose + route a
  multi-step task), `explorer` (read-only investigation), `implementer` (make
  the change), `reviewer` (adversarially verify before trusting). Run
  independent units in parallel; pass each worker the skills/memories you found.
- **Trivial turns stay inline.** A one-line answer or a mechanical edit does not
  need a subagent. Delegation is the default for real work, not a tax on chat.
- Full rationale and per-harness wiring: `~/.agents/docs/delegation.md`.

## Global skills (invoke on demand)

- `harness-ops` — create/modify skills, memories, hooks, harness config; skill-writing standards. **Use for any harness change.**
- `docs-sync` — create/refresh a project's `docs/` folder (seeds code repos with GitNexus).
- `context-manager` — recursive delegation + model routing for large tasks.
- `brainstorming` — requirements dialogue before creative/design work.
- `test-driven-development`, `systematic-debugging`, `verification-before-completion` — process discipline for code work.
- `no-mistakes` — local validation pipeline (tests, lint, push, PR, CI).
- `axi` (+ `gh-axi`, `chrome-devtools-axi`, `lavish-axi`) — agent-facing CLI standards and tools.
- `context7-mcp` — current library/framework docs.
- `terraform-skill` — Terraform/IaC work.
- `ui` — visual/front-end conventions: type roles, font stacks, webfont loading.

## Binding rules

1. Main context stays an index: summaries return, exploration goes to sub-agents.
2. Durable knowledge → a skill's `memory/`; volatile state → `STATUS.md`; documentation → `docs/`. Never bloat AGENTS.md.
3. Significant code/architecture changes update the project's `docs/` in the same session.
4. 100% accuracy from verified sources; mark `VERIFY` and escalate rather than invent.
5. Project-level AGENTS.md overrides this file inside its repo.
6. Always ask questions until complete clarification and provide suggestions.

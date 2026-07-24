# Delegation — auto-routing tasks to skill-aware subagents

*Purpose: how assigned tasks get handled by subagents that auto-pick skills and
memories, identically under Claude Code and pi. Last verified: 2026-07-24 (live).*

## Goal

Non-trivial tasks are not done in the main context. The main context
**orchestrates**: it discovers the relevant skills/memories, delegates the work
to worker subagents, and synthesises their results. This keeps the main context
an index (global rule 1) and makes each unit of work start from the right
knowledge instead of re-deriving it.

Two moving parts make this automatic:
1. a **shared subagent fleet** both harnesses read, and
2. a **skill selector** (`harness-skill-pick`) any agent can call to find the
   skills + memories that match a task.

## The fleet — `~/.agents/agents/*.md`

Canonical, git-tracked. Cross-tool markdown (YAML frontmatter `name` +
`description`; behavioural protocol in the body). Kept to the common frontmatter
both harnesses understand — the auto-pick protocol lives in the body, which both
read as the system prompt.

| agent | role |
|---|---|
| `orchestrator` | Decompose a multi-step task, route each part to a worker, synthesise. |
| `explorer` | Read-only investigation: locate code, map a subsystem, answer where/how. |
| `implementer` | Make the change (edits, new files, config, migrations). |
| `reviewer` | Adversarially verify a change/claim before it is trusted. |

Every worker body starts with the same instruction: **run `harness-skill-pick`,
read the surfaced `SKILL.md`s + `memory/`, read `STATUS.md`/`AGENTS.md`, then
act.** That is what "auto-picks skills/subskills and memories" means in practice.

Project-specific agents/overrides live in `<repo>/.agents/agents/*.md`
(scaffolded empty by `harness-init`); a project file wins over a global one of
the same name.

## The selector — `harness-skill-pick`

`bin/harness-skill-pick "<task keywords>"` scans the skill roots (project
`.agents/skills`, then global `~/.agents/skills`), parses each `SKILL.md`'s
`description`, ranks by how many task keywords match name+description, and prints
the top skills with their `SKILL.md` path and any `memory/*.md` files. `-a` shows
the full menu; `-n N` caps the count. It is the **single source of truth** for
skill selection — both harnesses use the same logic through it.

## Per-harness wiring

**Claude Code** — reads the fleet from `~/.claude/agents` and skills from
`~/.claude/skills` (committed *relative* symlinks inside the whole-dir-linked
`~/.claude` → `.../agentic-harness/claude`: `claude/agents → ../agents/agents`,
`claude/skills → ../agents/skills`). The main loop delegates per the
`AGENTS.md` "Delegation protocol" section and spawns workers with the `Agent`
tool; workers call `harness-skill-pick` via Bash and load skills with the Skill
tool. "Claude extension" = fleet + selector CLI + the self-heal SessionStart hook.

**pi** — `@tintinweb/pi-subagents` (installed, in `settings.json` packages)
provides Claude-Code-style subagents. It reads custom agents from
`~/.pi/agent/agents` (`pi/agent/agents → ../../agents/agents`) and
`<cwd>/.agents/agents`, and preloads skills from `.agents/skills` / `~/.agents/skills`.
"pi extension" = `pi/agent/extensions/pi-harness-delegate/` — registers a
`pick_skills` tool that wraps `harness-skill-pick` so a pi subagent discovers the
right skills/memories the same way.

Because a project has `.claude → .agents`, its `.agents/agents/` and
`.agents/skills/` are read by **both** harnesses with no duplication.

## Self-heal

Whole-dir symlinking of `~/.claude`/`~/.pi` can drop the inner `skills`/`agents`
links (this happened 2026-07-24, leaving Claude with zero skills).
`bin/harness-heal` (run first thing by the SessionStart hook, and on demand)
recreates any missing/broken link and is a no-op when they resolve correctly —
it never rewrites a good committed link, so no git churn.

## Setup command

`harness-init [dir]` (idempotent; also auto-run by the SessionStart hook in any
unharnessed git repo) scaffolds the per-project layout including `.agents/agents/`
and `.agents/skills/`. It never overwrites existing files.

## VERIFY

- pi auto-discovery of a loose extension dir under `~/.pi/agent/extensions/` is
  assumed from the gortex precedent but not re-verified for `pi-harness-delegate`.
  Smoke test: `pi list` should show it; else load with
  `pi -e ~/.pi/agent/extensions/pi-harness-delegate/index.ts` and, if needed, add
  it to `~/.pi/agent/settings.json`. Confirm the `pick_skills` tool appears.

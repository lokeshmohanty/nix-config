# Delegation — auto-routing tasks to skill-aware subagents

*Purpose: how assigned tasks get handled by subagents that auto-pick skills and
memories, identically under Claude Code and pi. Last verified: 2026-08-01 (the
`pi-agent` executor tested live; the rest of the wiring last verified 2026-07-24).*

> **pi is the executor (standing request, 2026-08-01).** Subagentic work is run
> by pi, from either harness, via `bin/pi-agent`. Claude's own `Agent` tool is
> reserved for when the user asks for it. The fleet files below remain the single
> definition of each worker; `pi-agent` is only the dispatcher. Hooks follow the
> same principle — see [hooks.md](hooks.md) and `bin/pi-nudge`.

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

## The executor — `pi-agent`

`pi-agent <explorer|implementer|reviewer|orchestrator|path.md> "<task>"` runs the
fleet body as a headless pi session in the current repo.

| | |
|---|---|
| agent resolution | `<repo>/.agents/agents/<name>.md` first, then `~/.agents/agents/<name>.md`; a path or `*.md` argument is used as-is |
| how the body is applied | `--append-system-prompt <file>` |
| tools | `explorer`/`reviewer` → `read,bash`; everything else → `read,bash,edit,write`. The read-only pair keeps `bash` because grep, git and `harness-skill-pick` are how they work |
| context | `--no-context-files`: no AGENTS.md auto-load. The worker reads what its body tells it to, so its context is scoped to the task |
| skills | discovery left **on** — project and global `SKILL.md`s are available |
| env | `PI_AGENT_TIMEOUT` (900), `PI_AGENT_MODEL`, `PI_AGENT_THINKING` (medium), `PI_AGENT_EPHEMERAL=1` for `--no-session` |
| output | worker report on stdout, one dispatch line on stderr; exit status is pi's (124 on timeout, with a note) |

**`-ne` (extensions disabled) is load-bearing, not tidying.** The pi
permission-system extension prompts before a bash call, and under `-p` there is
nobody to answer — the worker hangs to its timeout and returns nothing. Verified
2026-08-01: an identical prompt returns empty with extensions loaded and works
with `-ne`. The cost is that `pick_skills` (the `pi-harness-delegate` extension)
is unavailable inside a worker, which is why the fleet bodies invoke
`harness-skill-pick` over bash instead — same selector, same output.

Smoke test, 2026-08-01: `pi-agent explorer "which file registers the MDX
components and what is the exact export name?"` answered
`src/components/mdx.tsx:94`, `mdxComponents`, correctly, in ~20s.

## Per-harness wiring

**Claude Code** — reads the fleet from `~/.claude/agents` and skills from
`~/.claude/skills` (committed *relative* symlinks inside
`.../agentic-harness/claude`: `claude/agents → ../agents/agents`,
`claude/skills → ../agents/skills`). The main loop delegates per the `AGENTS.md`
"Delegation protocol" section, **dispatching workers with `pi-agent` over Bash**
rather than the `Agent` tool (2026-08-01); each worker then calls
`harness-skill-pick` itself. "Claude extension" = fleet + selector CLI +
`pi-agent` + the self-heal SessionStart hook.

Note both `~/.claude` and `~/.claude2` are in use on this machine and share the
same nix-managed `settings.json` by symlink; one hook registration covers both.
The 2026-08-01 incident in [hooks.md](hooks.md) is what happens when those inner
`claude/{agents,skills}` symlinks get deleted — Claude silently loses its fleet
and skills, which is exactly what `harness-heal` exists to repair.

**pi** — `@tintinweb/pi-subagents` (installed, in `settings.json` packages)
provides Claude-Code-style subagents. It reads custom agents from
`~/.pi/agent/agents` (`pi/agent/agents → ../../agents/agents`) and
`<cwd>/.agents/agents`, and preloads skills from `.agents/skills` / `~/.agents/skills`.
"pi extension" = `pi/agent/extensions/pi-harness-delegate/` — registers a
`pick_skills` tool that wraps `harness-skill-pick` so a pi subagent discovers the
right skills/memories the same way.

**Since 2026-07-27 the subagent tools are deferred in pi.** `Agent`/`get_subagent_result`/
`steer_subagent` are registered but inactive at session start (they cost 2,694 tokens
of schema); the model activates them with `load_tools(["subagents"])`, or you run
`/load-tools subagents`. `pick_skills` stays always-on, so skill discovery still
happens before delegation. Rationale and measurements: [pi-context-budget.md](pi-context-budget.md).

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

- ~~pi auto-discovery of a loose extension dir under `~/.pi/agent/extensions/`~~
  **Resolved 2026-07-27:** confirmed working. `pi.getAllTools()` reports
  `pick_skills` with `sourceInfo.path` = `~/.pi/agent/extensions/pi-harness-delegate/index.ts`
  with no `settings.json` entry, so loose dirs under `extensions/` are auto-loaded.
  (`pi list` shows only npm *packages*, not loose dirs — it is the wrong smoke test.)

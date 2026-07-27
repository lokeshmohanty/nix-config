# Project Template — what every repo must have

*Purpose: the contract `harness-init` scaffolds and audits against. Last verified: 2026-07-18.*

Source files: `~/.nix/config/agentic-harness/templates/project/`.

| Item | Role | Tracked? |
|---|---|---|
| `AGENTS.md` | Small index: what the project is, map to STATUS/docs/skills, binding rules. Keep under ~60 lines. | yes |
| `CLAUDE.md → AGENTS.md` | Compatibility symlink for Claude Code. | yes (as symlink) |
| `STATUS.md` | Volatile state: current focus, next actions, open obligations, **and the `# TODO(user added)` inbox**. Updated in place. **Referenced on demand — never "read this next".** No separate `TODO.md`. | yes |
| `docs/` | Full project documentation, plain markdown (see `docs-sync` skill for structure). | yes |
| `.agents/skills/` | Project skills, each `SKILL.md` + optional `memory/`. | yes |
| `.claude → .agents` | Compatibility symlink. | yes (as symlink) |
| `.gitignore` additions | Ignore harness runtime: `.claude/settings.local.json`, `.agents/*.lock`, `.gitnexus/`, `graphify-out/`. | yes |

Division of knowledge (never duplicate, always link):
- **docs/** — what the project *is* and how to use/change it (for any LLM, incl. pi).
- **skills + memory/** — how to *work on* it well (procedures, traps, decisions agents need mid-task).
- **STATUS.md** — what is true *right now*.
- **AGENTS.md** — the index over all of the above.

## The AGENTS.md-is-the-only-load rule (2026-07-27)

**Only `AGENTS.md` is auto-loaded.** No harness ever auto-loads `STATUS.md` —
verified against the Claude `SessionStart`/`Stop` hooks and pi's context loading,
which read `AGENTS.md`/`CLAUDE.md` only. What actually loads `STATUS.md` is
`AGENTS.md` *telling every session to read it*. Thesis' `AGENTS.md` did exactly
that and its `STATUS.md` reached 57KB (~14k tokens) charged to every task,
including one-line answers and subagent spawns.

So `AGENTS.md` must point at `STATUS.md` **on demand**, naming the conditions
(current state, recent decisions, open obligations, the TODO inbox) and preferring
`grep` over a whole-file read. Never "read `STATUS.md` next" or "read after this
file". Scoped pointers are fine and encouraged — *"before acting on X, read the
X section"* — because they fire per task, not per session.

The user's TODO inbox is a `# TODO(user added)` section **inside `STATUS.md`**, not
a separate `TODO.md`; one file, so a session that does need state gets the inbox in
the same read. Keep `STATUS.md` under ~10KB — past that, split the archive out
rather than making every session that needs *any* state pay for all of it.

## Scaffolding and migration

- **New repos:** the Claude SessionStart hook (`harness-session-start`) creates
  missing pieces in any git repo that has none of them (never overwrites; skips
  non-git and throwaway dirs). Manual: `harness-init [dir]`. Templates already
  encode the rule above.
- **From inside pi:** `/harness-ops audit|migrate [dir|all]` (extension
  `pi/agent/extensions/harness-ops/`) runs the same thing and puts the report in
  the model's context, so it can hand-fix what `--migrate` won't touch.
- **Existing repos:** `harness-init --audit [dir]` is read-only and reports drift
  (mandating language in `AGENTS.md`, a stray `TODO.md`, a missing inbox section, an
  oversized `STATUS.md`). `harness-init --migrate [dir]` applies only the mechanical
  fixes — merges `TODO.md` into `STATUS.md` verbatim under the inbox header and
  relaxes the exact template sentence. Prose it cannot rewrite safely is printed for
  a human or agent to edit; it is never regexed.
- Existing repos with their own conventions (e.g., a rich CLAUDE.md): convert by
  making AGENTS.md canonical and symlinking CLAUDE.md to it — content wins, names
  are fixed.

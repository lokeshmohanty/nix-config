---
name: harness-ops
description: >
  Create or modify anything in the agent harness: skills, skill memories, hooks,
  extensions, plugins, harness config, project scaffolding. Use BEFORE touching any
  file under ~/.agents, ~/.nix/config/agentic-harness, a project's .agents/, or any
  harness settings file. Also the replacement for find-skills / writing-skills /
  skill-creator.
---

# Harness Ops

## Ground truth

- Canonical global tree: `~/.nix/config/agentic-harness/` (git-tracked in `~/.nix`).
  `~/.agents` is a symlink to its `agents/` subdir. Live edits through `~/.agents`
  therefore land in the nix repo — **commit `~/.nix` after any harness change.**
- Layout spec, per-harness capabilities (claude/pi/codex/gemini hooks, extensions,
  skill formats), and tool docs: `~/.agents/docs/` — read `docs/index.md` first,
  then the specific page. Do not guess capabilities; if a page is missing or stale,
  fix it as part of your change.
- Project harness lives in the project repo: `AGENTS.md` + `STATUS.md` + `docs/` +
  `.agents/skills/`. Scaffold with `harness-init` (in `~/.nix/config/agentic-harness/bin/`).

## Context-budget rule (binding, 2026-07-27)

**`AGENTS.md` is the only file that auto-loads. Never write an instruction that
makes another file load every session.** No harness auto-loads `STATUS.md`; what
loads it is `AGENTS.md` saying "read this next". Thesis' `STATUS.md` reached 57KB
(~14k tokens) charged to every task that way.

When writing or editing any `AGENTS.md` (global or project):
- Point at `STATUS.md` **on demand**, with the conditions that justify the read
  (current state, recent decisions, open obligations, TODO inbox) and a nudge to
  `grep` the section instead of reading the file. Banned phrasings: "read
  `STATUS.md` next", "read after this file", "X + `STATUS.md` are all that loads".
- **Scoped pointers are good** — *"before acting on the environment grid, read that
  section"* fires per task, not per session. Prefer them to blanket mandates.
- The user's inbox is a `# TODO(user added)` section **inside `STATUS.md`**. Never
  create a separate `TODO.md`.
- Keep `STATUS.md` under ~10KB; past that split the archive out.

Same rule for tools: schemas are context too. Before adding a package/MCP server
globally, check what its schemas cost — in pi they were 74% of startup context, now
deferred via the `lazy-tools` extension. See `~/.agents/docs/pi-context-budget.md`
for the measurement method (it applies to any harness).

**Applying it:** new repos get it from the templates. For existing repos run
`harness-init --audit [dir]` (read-only drift report), then `harness-init --migrate
[dir]` for the mechanical fixes — it merges `TODO.md` into `STATUS.md` verbatim and
relaxes the exact template sentence, and *prints* any other mandating prose for you
to edit by hand rather than regexing it. Inside pi, the same thing is
`/harness-ops audit|migrate [dir|all]`. Contract: `~/.agents/docs/project-template.md`.

When a `STATUS.md` is already oversized, splitting it is a judgement call, not a
script: move only unambiguously historical blocks into the project's
`docs/content/design-history/` (verbatim, with a one-line pointer left behind), and
keep anything that describes what is true *now*. Worked example — Thesis, 2026-07-28:
848 → 382 lines by moving 4 blocks; verify with a content-line diff that nothing was
lost, and `zola check` if docs/ is a Zola site.

## Creating a skill (global or project)

1. Decide scope: useful across projects → `~/.agents/skills/<name>/`; project-specific
   → `<repo>/.agents/skills/<name>/`.
2. `SKILL.md` with YAML frontmatter: `name` (kebab-case) and `description` — the
   description is the trigger; write it as "Use when …" with concrete cues. Body:
   only what an agent needs to act, in imperative voice. Big reference material goes
   in sibling files, linked from SKILL.md, never inlined.
3. Create `memory/` beside SKILL.md when the skill accumulates durable knowledge.
   One topic per file, a pointer line in SKILL.md. Memories record what is NOT
   derivable from code/git: decisions, traps, conventions, escalation rules.
4. Keep SKILL.md under ~150 lines. If it grows past that, split into references.
5. Standards and rationale for skill writing: `references/anthropic-best-practices.md`,
   `references/gotchas.md`, `references/examples.md` (read when authoring anything
   non-trivial).

## Creating memories

- Trigger: you learned something durable (a trap, a decision, a working procedure)
  that a future session would otherwise re-derive.
- Location: the owning skill's `memory/`; if no skill owns it, consider whether a
  skill should exist. Project-wide volatile state → `STATUS.md` instead.
- Format: short markdown, dated facts, absolute dates, links to files by path.

### Linking memories

Link related memories with `[[name]]` instead of restating them — one fact lives in
one memory, everything else points at it. This is the anti-rule ("never create a
second source of truth") made mechanical.

- `[[name]]` resolves in the owning skill's `memory/` first, then sibling skills in
  the same project, then global skills. `[[../../other-skill/memory/name]]`,
  `[[name|alias]]` and `[[name.md]]` all work; ambiguity is reported, never guessed.
- A `[[link]]` to a memory that does not exist yet is fine — it marks something
  worth writing. It will show up as broken until you write it, which is the point.
- **Reference another memory as `[[name]]`, never as a path.** A backticked
  `research/memory/verdicts.md` rots on a skill rename exactly like a link does,
  but nothing checks it. Paths to *non-memory* files (`STATUS.md`, a `.typ`, a
  repo doc) stay as plain paths — the convention is for memory→memory only.
- **Resolve and audit the graph with `harness-memory-links`:**
  - `harness-memory-links` — graph summary, every broken link, and every
    plain-path reference that should be a `[[link]]` (with the exact replacement)
  - `harness-memory-links --of <skill>/<memory>` — that memory's outgoing links
    (with real paths to read next), its backlinks, and its broken links
  - `harness-memory-links --check` — broken links only, exit 1 if any
- Run `--check` after renaming or deleting any memory; a rename silently orphans
  every `[[link]]` pointing at the old name.
- **A green check only proves the target exists, not that it is the right one.**
  When repointing a link, confirm the target by content — the memory that
  actually defines the thing being referenced.

## Modifying hooks / extensions / plugins / settings

1. Read `~/.agents/docs/hooks.md` and `~/.agents/docs/harnesses.md` for what each
   harness supports and where its config lives.
2. Edit the canonical copy under `~/.nix/config/agentic-harness/` when the file is
   nix-managed (claude settings.json, pi settings/models, hook scripts in `bin/`);
   edit live files only for machine-local state (settings.local.json, auth, trust).
3. Keep hooks fast (<1s no-op path) — they run in every session.
4. Update the relevant page in `~/.agents/docs/` in the same change.
5. Commit `~/.nix`.

## Memory

- `memory/pi-rich-renderer-fork.md` — why `pi/agent/extensions/rich-renderer/` is a
  vendored fork of the npm package, the two upstream bugs it fixes (kitty `c`/`r`
  aspect collapse, math matcher deleting prose), how to test it under
  `node --experimental-strip-types`, and which terminals render its output
  reliably (kitty yes; ghostty drops placeholders in mixed streams).

## Anti-rules

- Never inline skill/memory content into AGENTS.md (global or project) — index only.
- Never store secrets (API keys, tokens) in the nix repo; those stay in live
  machine-local files (`settings.local.json`, `auth.json`, codex `config.toml`).
- Never create a second source of truth: if content exists in docs/ or a memory,
  link it.

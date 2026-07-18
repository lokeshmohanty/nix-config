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

## Modifying hooks / extensions / plugins / settings

1. Read `~/.agents/docs/hooks.md` and `~/.agents/docs/harnesses.md` for what each
   harness supports and where its config lives.
2. Edit the canonical copy under `~/.nix/config/agentic-harness/` when the file is
   nix-managed (claude settings.json, pi settings/models, hook scripts in `bin/`);
   edit live files only for machine-local state (settings.local.json, auth, trust).
3. Keep hooks fast (<1s no-op path) — they run in every session.
4. Update the relevant page in `~/.agents/docs/` in the same change.
5. Commit `~/.nix`.

## Anti-rules

- Never inline skill/memory content into AGENTS.md (global or project) — index only.
- Never store secrets (API keys, tokens) in the nix repo; those stay in live
  machine-local files (`settings.local.json`, `auth.json`, codex `config.toml`).
- Never create a second source of truth: if content exists in docs/ or a memory,
  link it.

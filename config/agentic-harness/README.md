# agentic-harness

Canonical, git-tracked source of the cross-harness agent setup (Claude Code, pi,
Codex, Gemini). AGENTS.md-first: every harness reads the same `agents/` tree;
`CLAUDE.md`, `GEMINI.md`, `APPEND_SYSTEM.md` are compatibility symlinks.

- Full layout + symlink map: `agents/docs/layout.md`
- Per-harness capabilities: `agents/docs/harnesses.md`
- Applied by `~/.nix/home/activations.nix` (`home-manager switch`, or run the same
  `ln -sfn` commands manually — idempotent).
- `bin/harness-init` scaffolds any project; a Claude SessionStart hook does it
  automatically for unharnessed git repos.

Change discipline: edit here (or through the `~/.agents` symlink), update
`agents/docs/`, commit this repo. Secrets never live here.

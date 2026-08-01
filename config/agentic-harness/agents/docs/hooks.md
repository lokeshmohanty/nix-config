# Hooks — inventory + how to add one

*Purpose: the current hook inventory across all harnesses and the registration recipe per harness. Every new hook must be recorded here. Last verified: 2026-08-01 (Claude global section read against the live `claude/settings.json`; other sections still carry their 2026-07-18 verification).*

## Rules

1. **<1s on the no-op path.** Hooks fire constantly; anything slow taxes every session.
2. **Nix-manage hook scripts** in `~/.nix/config/agentic-harness/bin/` — never loose scripts in `~/.local/bin` for harness hooks. (`home/activations.nix` symlinks all of `bin/*` into `~/.local/bin`, so a new script is on PATH after the next `home-manager switch`; hooks call it by absolute path regardless.)
3. **Document every new hook on this page** (what, event, harness, script path).
4. **The screen is deterministic; the judgement goes to pi.** Standing request,
   2026-08-01: a hook decides *whether* to fire in bash/python — cwd, git state,
   markers, one-per-session guards — and then hands the actual wording to a pi
   subagent through `bin/pi-nudge`, with only that hook's context. Rule 1 is
   unaffected because pi is never reached on the no-op path. Every nudge keeps a
   static fallback that is printed verbatim if pi is missing, errors, or times
   out, and `pi-nudge` treats a reply of `SILENT` as "screen fired, nothing worth
   saying" so the hook goes quiet instead of nagging.

### `pi-nudge` — the shared wrapper

`pi-nudge <name> <fallback-file|-> [context-file...]`, task prompt in
`PI_NUDGE_TASK`. Runs `pi -p -nc -ns -nt --no-session --thinking off`: no
AGENTS.md, no skills, no tools, no session, nothing but the prompt and the
context files the hook chose to pass. Env knobs: `PI_NUDGE_TIMEOUT` (default 60),
`PI_NUDGE_MODEL`.

**Budget the timeouts as a chain.** Measured 2026-08-01 against the ziq GLM-5.2
router: 10–20s typical for a nudge-sized prompt, but variable enough that 45s
produced a spurious fallback on an identical shape. Hence `pi-nudge` at 60s, and
the registered hook `timeout` at **90s** — the registered timeout must exceed
pi's, or Claude kills the hook before the fallback can print. `UserPromptSubmit`
hooks block the turn from starting, so they run on a tighter budget (25s).

## Current inventory (post 2026-07-18 restructure)

### Claude Code — global `~/.claude/settings.json` (nix-managed)

| Event | Hook | What it does |
|---|---|---|
| SessionStart | `harness-session-start` | Auto-scaffolds `AGENTS.md`/`STATUS.md`/`docs/`/`.agents` in unharnessed git repos. Script: `.../bin/harness-session-start`. Timeout 10s. Deterministic — no pi handoff (see below). |
| Stop | `docs-nudge` | Screens for "tracked source changed, `docs/` didn't", then asks pi which page is now stale, given the diff and the docs ToC. Script: `.../bin/docs-nudge`. Timeout 90s. |
| Stop | `skill-memory-nudge` | Screens for "a skill was used, no memory was written", then asks pi what this session's user messages actually contained that must be captured, and where. Script: `.../bin/skill-memory-nudge`. Timeout 90s. |

**Incident, 2026-08-01 — read this before trusting a live settings file.** While
adding `skill-memory-nudge`, the live `claude/settings.json` was found trimmed to
`model`/`theme`/`enabledPlugins`: no `hooks` block, no `permissions`, no
`attribution`, `model` downgraded from `opus[1m]` to `opus`, and 5 of 6
`enabledPlugins` gone. That was taken at face value and this page was "corrected"
to say the hooks had never been registered. **Both were wrong.** The committed
file did have `harness-session-start` and `docs-nudge` registered exactly as the
2026-07-18 entry claimed; the *live* file had been rewritten by the app (a
re-login is the likely trigger), and writing to it persisted the loss into the
nix repo, where an auto-commit (`26f381d`) captured it along with the deletion of
`claude/{.gitignore,CLAUDE.md,agents,skills,rules/context7.md}` — including the
committed relative symlinks that give Claude its skills and fleet. Restored from
`26f381d^` the same day. Lessons: **diff a live harness file against `git show
HEAD:<path>` before writing to it**, and treat an unexpectedly minimal config as
evidence of a clobber rather than as ground truth.

`skill-memory-nudge` (added 2026-08-01, standing request): the harness's skills
are supposed to learn from each use, and a session that takes feedback without
writing it down throws it away. Fires only when both conditions hold — the
transcript shows a skill was loaded or invoked, *and* no `.md` under any memory
root has an mtime later than the session's first transcript record. Roots are
the global tree (`~/.agents/skills/*/memory`), the current repo's project skills
(`<root>/.agents/skills/*/memory`), and Claude's per-project auto-memory store
(`~/.claude*/projects/<slug>/memory`, where the slug is the repo path with both
`/` and `.` flattened to `-`). Guarded by `stop_hook_active` and a per-session
marker in `$TMPDIR`, so it nudges at most once, and it exits before any
filesystem walk when no skill was used. Measured ~265 ms on the no-op path,
python startup dominating; ~13s when it fires and pi answers. Registered in the
nix-managed `claude/settings.json`, which **both** `~/.claude` and `~/.claude2`
symlink to — one registration covers both config dirs.

What it hands pi is deliberately narrow: **only Lokesh's own messages** from the
transcript (assistant prose, tool results and file contents are dropped — they
are what makes a transcript expensive and they are not evidence of what he
asked for), plus the list of memory roots. pi then names the specific
corrections and which skill's `memory/` should hold each. Verified 2026-08-01
against a synthetic transcript: it picked out a durable convention, ignored
`"continue"`, and answered `SILENT` for a session containing only mechanical
instructions.

`harness-session-start` is the **one hook that stays fully deterministic**. It
scaffolds missing files and heals symlinks; there is no judgement in it, it runs
on *every* session start, and an LLM in that path would add latency and
nondeterminism to a `mkdir`. If it ever needs to decide something, that decision
is what should go to `pi-nudge` — not the scaffolding.

### AXI SessionStart hooks — REMOVED 2026-07-27

The three AXI announcement hooks (`gh-axi`, `chrome-devtools-axi`, `lavish-axi`) were removed from **both** the Claude `settings.json` and Codex `~/.codex/hooks.json` on 2026-07-27. Two reasons:

1. They had been failing since installation. They were registered by each tool's `setup hooks` subcommand, which assumes a global `npm install -g`; on NixOS that never persisted, so all three fired against an empty PATH and errored on every session start.
2. Even working, they were unconditional context injections in every repo. `lavish-axi`'s announcement alone is ~2k tokens of playbooks and design guidance; `gh-axi` and `chrome-devtools-axi` are ~5 lines each.

**Replacement:** the CLIs are now installed declaratively on PATH via the `axi-tools` nix package (`~/.nix/pkgs/axi-tools`, wired through `pkgs/default.nix` → `home/ai.nix`), and the `gh-axi` / `chrome-devtools-axi` / `lavish-axi` skills trigger on demand. Each skill's SKILL.md was rewritten the same day to call the on-PATH binary directly (not `npx`) and to tell the agent to run the bare command once to orient — which is what the hook used to supply, but only when relevant.

**Do not re-run `<tool> setup hooks`.** It reinstalls these hooks. If a tool is ever missing, fix the nix package instead; version-bump steps are in the header of `~/.nix/pkgs/axi-tools/default.nix`.

### Thesis repo (`~/Documents/Research/LiteratureSurvey/.claude/settings.json` → `.agents/settings.json`)

| Event | Hook | What it does |
|---|---|---|
| UserPromptSubmit | `research-critic-nudge` | Added 2026-07-22. Keeps the adversarial ICLR-spotlight reviewer in play without the user asking: on prompts that look like a *research decision* (keyword screen over the prompt), injects the research-gate chain — theorist (theory grounding / novel falsifiable hypothesis, novelty-checked against litgraph) then critic (adversarial ICLR-spotlight review; a HARD GATE for experiment plans). Silent for non-thesis cwd and for mechanical prompts. Script: `~/.nix/config/agentic-harness/bin/research-critic-nudge` (no-op path ~23 ms). **Since 2026-08-01** the reminder is written by pi (`pi-nudge`, 25s budget) from the prompt alone, so it names the actual decision being made; the keyword `case` statement still does the screening, and the old static text is the fallback. Verified: a baseline/ablation prompt produced a decision-specific gate, a "fix the typo in the results section" prompt produced `SILENT`, and a non-thesis cwd still exits in ~23 ms. |

### Gortex hooks — REMOVED globally 2026-07-18, now per-repo only

Global `~/.claude/settings.local.json`, Codex `config.toml`, and Gemini `settings.json` no longer carry gortex hooks (removed 2026-07-18). Per-repo scoping below is live.

Gortex hooks now live **only** in `<repo>/.claude/settings.local.json` of the three zenteiq repos (verified present, 5 hook entries each):

- `/home/lokesh/Projects/zenteiq/brahmx/dsdg`
- `/home/lokesh/Projects/zenteiq/prime-rl`
- `/home/lokesh/Projects/zenteiq/verifiers`

Events in each: `SessionStart`, `UserPromptSubmit`, `PreToolUse` (matcher `Read|Grep|Glob|Task|Bash|Edit|Write|mcp__gortex__read_file|mcp__gortex__get_editing_context`), `Stop`, `PreCompact` — all invoking `/home/lokesh/.local/bin/gortex hook`.

### Codex — `~/.codex/hooks.json`

Emptied to `{"hooks": {}}` on 2026-07-27 — it carried only the three AXI SessionStart hooks (see the removal note above). Note this file is **not** nix-managed: it is a live file in `~/.codex/`, unlike the Claude settings. Gortex hooks removed from `config.toml` 2026-07-18; stale `[hooks.state]` trust hashes for them remain (harmless).

### Gemini — `~/.gemini/settings.json`

Cleaned 2026-07-18: gortex MCP registration and the graphify-hint `BeforeTool` hook removed; no hooks currently configured.

### pi

No hook events. Customization goes through extensions (`~/.pi/agent/extensions/`).

## How to register a hook

### Claude Code (any settings.json — global, local, or per-repo)

Events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `PreCompact`. `matcher` is a regex over tool names (Pre/PostToolUse) or source (SessionStart); empty string = match all. `timeout` is in **seconds** in the global file's existing entries (VERIFY: repo-local gortex entries use `3000`/`5000`, i.e. ms-style values — the two conventions coexist live; check Claude Code docs before copying).

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/home/lokesh/.nix/config/agentic-harness/bin/harness-session-start",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/home/lokesh/.nix/config/agentic-harness/bin/docs-nudge",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Hook contract: stdin gets a JSON event payload; stdout text is injected as context (or, for PreToolUse, a JSON `{"decision": ...}` can gate the call). Non-zero exit with stderr blocks (PreToolUse) or surfaces a warning.

### Codex (`~/.codex/config.toml`)

```toml
[[hooks.PreToolUse]]
matcher = '^Bash$'

[[hooks.PreToolUse.hooks]]
command = '/home/lokesh/.nix/config/agentic-harness/bin/my-hook'
statusMessage = 'Running my-hook...'
timeout = 5
type = 'command'

[[hooks.SessionStart]]
matcher = 'startup|resume|clear|compact'

[[hooks.SessionStart.hooks]]
command = "printf '%s\\n' 'context line to inject'"
timeout = 5
type = 'command'
```

Codex also reads `~/.codex/hooks.json` (same JSON shape as Claude). After adding/editing a hook, Codex records a `trusted_hash` under `[hooks.state]` on first approval — changing the command invalidates it and re-prompts.

### Gemini (`~/.gemini/settings.json`)

Same nested JSON shape as Claude but event names `SessionStart` / `BeforeTool` / `AfterTool`, entries take `name` + `description` fields, `timeout` in ms. Trust recorded in `~/.gemini/trusted_hooks.json`.

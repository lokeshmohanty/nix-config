# Hooks — inventory + how to add one

*Purpose: the current hook inventory across all harnesses and the registration recipe per harness. Every new hook must be recorded here. Last verified: 2026-07-18 (live system; restructure of the same date partially applied — pending items flagged).*

## Rules

1. **<1s on the no-op path.** Hooks fire constantly; anything slow taxes every session.
2. **Nix-manage hook scripts** in `~/.nix/config/agentic-harness/bin/` — never loose scripts in `~/.local/bin` for harness hooks.
3. **Document every new hook on this page** (what, event, harness, script path).

## Current inventory (post 2026-07-18 restructure)

### Claude Code — global `~/.claude/settings.json` (nix-managed)

| Event | Hook | What it does |
|---|---|---|
| SessionStart | `gh-axi` | AXI CLI announcement (GitHub ops) |
| SessionStart | `chrome-devtools-axi` | AXI CLI announcement (headless Chrome) |
| SessionStart | `lavish-axi` | AXI CLI announcement |
| SessionStart | `harness-session-start` | Runs `harness-heal` first (repairs the cross-tool `skills`/`agents` symlinks), then auto-scaffolds `AGENTS.md`/`STATUS.md`/`docs/`/`.agents` in unharnessed git repos. Script: `~/.nix/config/agentic-harness/bin/harness-session-start` |
| Stop | `docs-nudge` | Reminds when tracked source changed but `docs/` didn't. Script: `~/.nix/config/agentic-harness/bin/docs-nudge` |

Applied 2026-07-18: the three AXI SessionStart hooks plus `harness-session-start` (SessionStart) and `docs-nudge` (Stop) are registered in the nix-managed settings.json; scripts live in `agentic-harness/bin/` (tested: scaffold, idempotency, one-nudge-per-session).

### Thesis repo (`~/Documents/Research/LiteratureSurvey/.claude/settings.json` → `.agents/settings.json`)

| Event | Hook | What it does |
|---|---|---|
| UserPromptSubmit | `research-critic-nudge` | Added 2026-07-22. Keeps the adversarial ICLR-spotlight reviewer in play without the user asking: on prompts that look like a *research decision* (keyword screen over the prompt), injects the research-gate chain: `research-theorist` (theory grounding / novel falsifiable hypothesis, novelty-checked against litgraph) then `research-critic` (adversarial ICLR-spotlight review; a HARD GATE for experiment plans). Silent for non-thesis cwd and for mechanical prompts. Script: `~/.nix/config/agentic-harness/bin/research-critic-nudge` (no-op path ~8 ms). |

### Gortex hooks — REMOVED globally 2026-07-18, now per-repo only

Global `~/.claude/settings.local.json`, Codex `config.toml`, and Gemini `settings.json` no longer carry gortex hooks (removed 2026-07-18). Per-repo scoping below is live.

Gortex hooks now live **only** in `<repo>/.claude/settings.local.json` of the three zenteiq repos (verified present, 5 hook entries each):

- `/home/lokesh/Projects/zenteiq/brahmx/dsdg`
- `/home/lokesh/Projects/zenteiq/prime-rl`
- `/home/lokesh/Projects/zenteiq/verifiers`

Events in each: `SessionStart`, `UserPromptSubmit`, `PreToolUse` (matcher `Read|Grep|Glob|Task|Bash|Edit|Write|mcp__gortex__read_file|mcp__gortex__get_editing_context`), `Stop`, `PreCompact` — all invoking `/home/lokesh/.local/bin/gortex hook`.

### Codex — `~/.codex/hooks.json`

Carries the same three AXI SessionStart hooks (`gh-axi`, `chrome-devtools-axi`, `lavish-axi`) in Claude-style JSON (verified). Gortex hooks removed from `config.toml` 2026-07-18; stale `[hooks.state]` trust hashes for them remain (harmless).

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

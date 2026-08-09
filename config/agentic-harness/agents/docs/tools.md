# Supporting tools — code intelligence & docs tooling

*Purpose: which code-intelligence / docs / media tool applies where, and current install state. Last verified: 2026-08-09 (screen-rec added; the rest 2026-07-18).*

## Decision guide

| Need | Tool |
|---|---|
| Structural reference for a code repo (seed `docs/reference/`) | GitNexus |
| Deep graph queries / safe edits in the three zenteiq repos | gortex |
| Current library/framework docs | context7 (`npx ctx7@latest`) |
| Papers / literature | litgraph (own repo, `litgraph-ops` skill) |
| Everything else | plain `docs/` markdown — the llm-wiki pattern |
| Resolve or audit `[[links]]` between skill memories | `harness-memory-links` (see `harness-ops`) |
| Record the screen, or turn a clip into a gif | `screen-rec` (below; pi's `/record` dispatches to it) |

## GitNexus (`abhigyanpatwari/GitNexus`)

- Zero-server code-graph engine. **NOT a git-history tool despite the name.**
- Verified current npm version: **1.6.9** (`npm view gitnexus version`). Not installed globally — invoked via npx.
- **Never wire it as a persistent MCP server.** A stale global `gitnexus` entry in `~/.claude.json` (pointing at a removed `~/.nix-profile/bin/gitnexus`) threw ENOENT in every session until removed 2026-07-27. npx-on-demand is the only supported path.
- `npx gitnexus@latest analyze` indexes a repo into `.gitnexus/` — an embedded Cypher-queryable DB. `.gitnexus/` is **gitignored**.
- Generates: markdown context files, per-area skills, and an MCP server exposing ~17 tools (VERIFY exact count per version).
- Fully local and deterministic — no LLM, no server, no API key. 14 supported languages (VERIFY list per version).
- Role here: the **docs-sync skill** uses it to seed `docs/reference/` in code repos; the hand-curated `docs/` pages then capture intent on top.

## gortex (daemon, `~/.local/bin/gortex`)

- Deep code graph + 90+ analyzers + safe-edit/review verbs, exposed as MCP server + CLI + hooks.
- **SCOPED to zenteiq repos only as of 2026-07-18**: `brahmx/dsdg`, `prime-rl`, `verifiers` (hooks live in each repo's `.claude/settings.local.json` — see [hooks.md](hooks.md)). Do not wire it into other repos.
- Config lives **per-repo**: `.mcp.json` (server) + `.claude/settings.local.json` (`enabledMcpjsonServers: ["gortex"]` + hooks). The contradicting global `mcpServers.gortex` entry in `~/.claude.json` was removed 2026-07-27 — it started the daemon in every project and reported INACTIVE outside the three repos. Do not re-add it globally.
- When it says "run `gortex track <dir>`" in an untracked repo, **ignore it** — that message is generic, not a recommendation for this harness.
- Daemon must be running for hooks/MCP to answer; otherwise tools are inert (MCP reports "INACTIVE" for untracked dirs).
- State: ~600MB verified (312M `~/.gortex` + 281M `~/.local/share/gortex`).
- Key verbs: `query`, `review`, `analyze`, `edit`, `wiki`, `wakeup`, `context` (plus `track`, `hook`, `mcp`).
- Extensive skill/command surface already installed: `gortex-*` skills and `~/.claude/commands/gortex-*.md`.

## graphify — REMOVED 2026-07-18

- Removed from the toolchain: litgraph covers papers, GitNexus covers code.
- Reinstall if ever needed: `pipx install graphifyy` (note the double-y package name).
- Removed 2026-07-18: binary deleted from `~/.local/bin/graphify`, `~/.graphify` data dir removed, gemini graphify-hint hook removed.

## context7

- Current library/framework documentation on demand; prefer over training data or web search for library docs (global rule: `~/.claude/rules/context7.md`).
- Two access paths:
  - **CLI:** `npx ctx7@latest library <name> "<question>"` → pick `/org/project` ID → `npx ctx7@latest docs <id> "<question>"` (no global `ctx7` binary installed; npx-resolved, v0.5.5 verified).
  - **MCP:** `context7` server registered in Claude (`~/.claude.json`), Codex (`[mcp_servers.context7]`), and Gemini (`mcpServers.context7`) — HTTPS endpoint with API key.

## screen-rec (`bin/screen-rec`, ours)

Screen recording + video conversion as an AXI CLI: `gpu-screen-recorder` for capture
(GPU-encoded, no measurable impact on the recorded session), `ffmpeg` for conversion,
`gifski` as an optional higher-quality gif encoder. TOON on stdout, progress on stderr,
exit 0/1/2. Run it with no arguments for live state + the command list; every subcommand
has `--help`.

- `start` … `stop` (also `pause`, `status`); `start --replay <sec>` keeps a rolling in-RAM
  buffer that `save` writes out. The recorder is `setsid`-detached and outlives the session
  that started it — state (pid, target, output) lives in `$XDG_RUNTIME_DIR/screen-rec/`.
- `convert <file> --format gif|mp4|webm|webp|png` with `--width/--fps/--start/--duration/--speed`.
  With no `<file>` it converts the most recent recording.
- Consumers: pi's `/record` command dispatches an `implementer` subagent that drives this CLI
  ([harnesses.md](harnesses.md)); a human runs the same commands directly. Nothing registers
  model tools, so none of this costs system-prompt context.

Machine facts verified 2026-08-09 (niri/Wayland, gsr 5.12.5), all encoded in the script:
monitor capture works by name (`eDP-1`) and via `screen` with no xdg-desktop-portal round trip;
`-w focused` is X11-only and is rejected with a pointer to `--region` (which uses `slurp`);
a replay buffer needs an integer kbps `-q` (CBR) **and** an explicit `-c mp4`, because `-o` is a
directory; animated webp must use `libwebp_anim` (plain `libwebp` came out ~12x larger) and
ffprobe cannot demux the result, so its dimensions are reported as unknown rather than `0x0`.

## The llm-wiki pattern (docs/-first philosophy)

> The *pattern* (Karpathy's) is what this section describes. The `@zosmaai/pi-llm-wiki`
> *package* was removed 2026-07-28 — it duplicated `memory/` and `docs/` and went
> unused. See [pi-context-budget.md](pi-context-budget.md#removed-zosmaaipi-llm-wiki-2026-07-28).

Hand- or agent-curated markdown is the primary knowledge store; graph tools only **seed structural reference**, they never replace curation:

- Every repo carries `AGENTS.md` (index) + `STATUS.md` (volatile state) + `docs/` (durable pages). Main context stays an index; detail lives one link away.
- `docs/` is plain markdown **deliberately** — the weakest harness model (pi's local 31B) must be able to answer from it with nothing but file reads.
- GitNexus seeds `docs/reference/` in code repos; humans/agents own everything else in `docs/`.
- Intent (why, decisions, invariants) goes in curated pages; structure (what calls what) is regenerable and stays in seeded reference or the graph DB.

See [layout.md](layout.md) for the full file layout, and the **docs-sync** skill for the upkeep workflow (the `docs-nudge` Stop hook enforces it — [hooks.md](hooks.md)).

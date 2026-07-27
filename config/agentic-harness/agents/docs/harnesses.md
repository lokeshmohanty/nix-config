# Harnesses — per-harness feature reference

*Purpose: what each installed agent harness supports (context files, skills, hooks, MCP, extensions, config locations) — consult before creating or modifying any harness component. Last verified: 2026-07-24 (live system).*

> Task delegation to skill-aware subagents (the shared `~/.agents/agents/` fleet,
> `harness-skill-pick`, and the Claude/pi wiring) is documented separately in
> [delegation.md](delegation.md).

## Summary table

| | Claude Code | pi | Codex | Gemini CLI | Antigravity |
|---|---|---|---|---|---|
| Context file | `~/.claude/CLAUDE.md` → `~/.agents/AGENTS.md`; project `CLAUDE.md` | `AGENTS.md`/`CLAUDE.md` from cwd + `APPEND_SYSTEM.md` → `~/.agents/AGENTS.md` | `~/.codex/AGENTS.md` → `~/.agents/AGENTS.md` | `~/.gemini/GEMINI.md` → `~/.agents/AGENTS.md` | `~/.gemini/antigravity/AGENTS.md` → `~/.agents/AGENTS.md` + project `AGENTS.md` |
| Skills | yes — `~/.claude/skills` → `~/.agents/skills` + `<repo>/.claude/skills` | yes — `~/.pi/agent/skills` → `~/.agents/skills`, `--skill` | yes — `~/.codex/skills` → `~/.agents/skills` | yes — `~/.gemini/skills` → `~/.agents/skills` (VERIFY discovery semantics) | yes — `~/.gemini/antigravity/skills` → `~/.agents/skills` |
| Hooks | yes — JSON in settings files (6 events) | no native hook events (extensions instead) | yes — `config.toml` `[[hooks.*]]` + `hooks.json` | yes — `settings.json` (`SessionStart`/`BeforeTool`/`AfterTool` naming) | no native hooks (VERIFY) |
| MCP | yes — `~/.claude.json` global, `.mcp.json` per-project | no (VERIFY — nothing configured; extensions cover tool needs) | yes — `[mcp_servers]` in config.toml | yes — `mcpServers` in settings.json | yes — `mcp_config.json` (nix-managed, empty; gortex removed) |
| Subagents | yes — `agents/*.md` global + per-repo | yes — via `@tintinweb/pi-subagents` (reads `~/.pi/agent/agents` + `.agents/agents`) | no | no (VERIFY) | no (VERIFY) |
| Plugins / extensions | plugins (`enabledPlugins`, marketplaces) | extensions (`~/.pi/agent/extensions/`, `pi install`) | no | `~/.gemini/extensions/` | plugins via `agy plugin`; IDE extensions in `~/.antigravity` |
| Config | `~/.claude/settings.json` (+ `.local`, per-project) | `~/.pi/agent/settings.json`, `models.json` | `~/.codex/config.toml` | `~/.gemini/settings.json` | `~/.gemini/antigravity/` (agent home) + `~/.antigravity` (IDE) |
| Nix-managed? | selective links (`CLAUDE.md`, `skills`, `settings.json`, `rules`); runtime dirs stay real | selective links (`settings.json`, `models.json`, `web-search.json`, `APPEND_SYSTEM.md`, `skills`) | AGENTS.md + skills links only — `config.toml` machine-local (secrets) | GEMINI.md link only | links for AGENTS.md, skills, mcp_config.json |

Symlink map and full file layout: [layout.md](layout.md).

---

## Claude Code (`~/.claude`)

**Config precedence (all JSON, deep-merged):**
- `~/.claude/settings.json` — global; symlink into `~/.nix/config/agentic-harness/claude/settings.json` (applied 2026-07-18). `settings.local.json` stays a real machine-local file.
- `~/.claude/settings.local.json` — machine-local, not nix-tracked.
- `<repo>/.claude/settings.json` — project, committed.
- `<repo>/.claude/settings.local.json` — project, gitignored.
- `<repo>/.mcp.json` — project MCP servers.

**Current global settings.json (verified):** `model: claude-fable-5[1m]`, `effortLevel: high`, `permissions.allow: [mcp__gortex__*]`, `defaultMode: auto`, 14 `enabledPlugins` all from marketplace `claude-plugins-official` (superpowers, context7, firecrawl, huggingface-skills, playwright, sourcegraph, code-review, code-simplifier, claude-md-management, frontend-design, playground, atomic-agents, lua-lsp, rust-analyzer-lsp), extra marketplace `claude-code-plugins` (github `anthropics/claude-code`). Plugin state lives in `~/.claude/plugins/` (`installed_plugins.json`, `known_marketplaces.json`).

**Features:**
- **Skills** — directories containing `SKILL.md` (+ optional `memory/`, `references/`, `tools/`). Global: `~/.claude/skills` → `~/.agents/skills` (12 skills verified). Per-repo: `<repo>/.claude/skills/`. Plugins also contribute skills (`plugin:skill` namespacing).
- **Hooks** — events `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `PreCompact`; registered as JSON in any settings file. Inventory and snippets: [hooks.md](hooks.md).
- **Subagents** — `~/.claude/agents/*.md` and `<repo>/.claude/agents/*.md`; markdown with frontmatter (name, description, tools, model). `~/.claude/agents` is a committed relative symlink → `../agents/agents` (the shared fleet: orchestrator/explorer/implementer/reviewer). Delegation protocol: [delegation.md](delegation.md).
- **Slash commands** — `~/.claude/commands/*.md` (currently 20 gortex-* commands) and `<repo>/.claude/commands/*.md`.
- **MCP servers** — global in `~/.claude.json` under `mcpServers` (verified: `context7`, `ghost`, `gortex`); per-project in `<repo>/.mcp.json`.
- **Auto memory** — per-project at `~/.claude/projects/<path-slug>/memory/` (`MEMORY.md` + topic files). Verified: e.g. `~/.claude/projects/-home-lokesh-Projects-zenteiq-brahmx-dsdg/memory/`.
- **Context loading** — `~/.claude/CLAUDE.md` → `~/.agents/AGENTS.md` (global, always loaded), plus the walked-up project `CLAUDE.md` (in this setup a symlink to the repo's `AGENTS.md`). Supports `@path/to/file` imports inside CLAUDE.md. Global rules dir: `~/.claude/rules/` (context7.md).

## pi (`~/.pi`) — binary from `numtide/llm-agents.nix`

Verified: `pi 0.82.0`, `/nix/store/…-pi-0.82.0/bin/pi`; flake input `llm-agents.url = "github:numtide/llm-agents.nix"` (`~/.nix/flake.nix:44`). Stale `~/.pi/pi` link removed 2026-07-18.

**Capability note:** pi runs against a **local 31B model** by default — keep its tasks simple: docs reading, routine edits, question-answering from `docs/` folders. The `docs/` folders across repos are plain markdown *specifically so pi can answer from them without tooling*.

**Config (`~/.pi/agent/`):**
- `settings.json` (verified 2026-07-27): `defaultThinkingLevel: medium`, 8 npm `packages` (listed under Extensions below). `defaultProvider`/`defaultModel` get hand-edited often — read the file, don't trust a value quoted here.
- `models.json` (verified 2026-07-27) — four providers, all `api: openai-completions`:
  - `vllm-gemma4-31` → `google/gemma-4-31B-it` (text+image) — local cluster
  - `vllm-qwen35-122` → `Qwen/Qwen3.5-122B-A10B` (text+image) — local cluster
  - `vllm-deepseek4-flash` → `deepseek-ai/DeepSeek-V4-Flash` (text) — local cluster
  - `sglang-glm5.2` → `GLM-5.2` (text+image, `maxTokens: 4096`) — `bose:8000`
- `web-search.json` at `~/.pi/web-search.json` (verified): provider `exa`, enabled.
- `trust.json`, `auth.json`, `sessions/` also live in `~/.pi/agent/`.

**Context:** reads `AGENTS.md`/`CLAUDE.md` from cwd automatically (`--no-context-files` / `-nc` to disable) plus `~/.pi/agent/APPEND_SYSTEM.md` → `~/.agents/AGENTS.md` (appended to system prompt).

**Skills:** `~/.pi/agent/skills` → `~/.agents/skills` — same skill set as Claude Code. Extra: `--skill <path>` to load ad-hoc, `--no-skills`.

**Extensions:** npm packages listed in `settings.json` `packages` (verified 2026-07-24: `@tintinweb/pi-subagents`, `pi-web-access`, `@zosmaai/pi-llm-wiki`, `pi-codex-goal`, `pi-observational-memory`, `pi-agent-browser-native`, `pi-rich-renderer`, `pi-image-tools`), plus loose dirs under `~/.pi/agent/extensions/`. `--extension/-e <path>`, `--no-extensions`; managed via `pi install/remove/update/list/config`. Extensions register flags, tools, commands, shortcuts, and event handlers (`export default (pi: ExtensionAPI) => { pi.registerTool({...}) }`). No hook events — extensions are the customization mechanism.
- **`pi-harness-delegate`** (`pi/agent/extensions/pi-harness-delegate/`, ours) — registers the `pick_skills` tool wrapping `harness-skill-pick`. See [delegation.md](delegation.md). (VERIFY loose-dir auto-discovery: `pi list`.)
- **`@tintinweb/pi-subagents`** — provides the `Agent`/`get_subagent_result`/`steer_subagent` tools and reads the shared fleet from `~/.pi/agent/agents` + `<cwd>/.agents/agents`; skill preloading from `.agents/skills`. **Deferred** — see `lazy-tools`.
- **`lazy-tools`** (`pi/agent/extensions/lazy-tools/`, ours) — see [pi-context-budget.md](pi-context-budget.md). Keeps the heavy packages installed but *inactive* at session start, so their schemas stay out of the system prompt; the model calls `load_tools(groups)` (or you run `/load-tools <group>`) to activate a group for the rest of the session. Groups: `subagents`, `browser`, `wiki`, `web`, `goal`, `memory`.
- **`harness-ops`** (`pi/agent/extensions/harness-ops/`, ours) — `/harness-ops audit|migrate [dir|all]`, a thin wrapper over `harness-init --audit/--migrate` so the project-harness contract can be enforced from inside pi. `all` sweeps every harnessed repo under `~/Projects`, `~/Documents/Research`, and `~/.nix`. Reports go through `pi.sendMessage({display:true})` so the model sees them too and can fix the mandating prose that `--migrate` deliberately refuses to rewrite. Contract: [project-template.md](project-template.md).

**Command handlers do not render return values.** Use `ctx.ui.notify(text, "info")` for short output or `pi.sendMessage({..., display:true}, {triggerTurn:false})` for multi-line content that the model should also see. (`pi.appendEntry()` is TUI-only and needs a registered entry renderer.) Action methods like `pi.getCommands()`/`pi.setActiveTools()` throw if called during extension load — call them from `session_start` or later.

**Other verified flags:** `--prompt-template <path>` / `--no-prompt-templates`, `--theme <path>` / `--no-themes`, `--thinking off..xhigh`, session mgmt (`-c` continue, `-r` resume, `--session`, `--session-id`, `--fork`, `--session-dir`, `--no-session`, `--name`, `--export <html>`), `--print/-p` non-interactive, `--mode text|json|rpc`, `--tools/--exclude-tools/--no-tools`, `--approve/-a` (trust project-local files), `--offline`, `--list-models`.

## Codex (`~/.codex`) — machine-local, NOT nix-managed

`~/.codex/config.toml` contains secrets (API keys in MCP headers; `auth.json` alongside) — **never commit, never symlink into ~/.nix**.

**Verified from config.toml:** `model = "gpt-5.5"`, `model_reasoning_effort = "xhigh"`, `service_tier = 'fast'`.
- **Hooks** — TOML tables `[[hooks.PreToolUse]]`, `[[hooks.PostToolUse]]`, `[[hooks.SessionStart]]` (with nested `[[hooks.<Event>.hooks]]` entries), plus a separate `~/.codex/hooks.json` (Claude-style JSON; currently carries the three AXI SessionStart hooks). Codex tracks per-hook trust hashes under `[hooks.state]` — editing a hook command requires re-trusting. See [hooks.md](hooks.md). Gortex hooks removed from config.toml 2026-07-18 (MCP server registration kept for zenteiq work).
- **MCP** — `[mcp_servers.<name>]` tables (verified: `context7` via HTTPS URL + API-key header).
- **Context** — `~/.codex/AGENTS.md` → `~/.agents/AGENTS.md`; also reads repo `AGENTS.md`.
- **Skills** — `~/.codex/skills` → `~/.agents/skills`.
- **Project trust** — `[projects.'/abs/path'] trust_level = 'trusted'` (verified: 11 trusted paths incl. `~/Projects/zenteiq/brahmx/dsdg`).

## Gemini CLI (`~/.gemini`) — brief

- Context: `~/.gemini/GEMINI.md` → `~/.agents/AGENTS.md` (note the filename is GEMINI.md, not AGENTS.md).
- Skills: `~/.gemini/skills` → `~/.agents/skills`. VERIFY: whether Gemini CLI actually discovers/loads this skills dir.
- Hooks: supported in `~/.gemini/settings.json` under `hooks` with event names `SessionStart`, `BeforeTool`, `AfterTool`. Gortex MCP + graphify hook removed 2026-07-18; hooks section currently empty. Trusted-hook state in `trusted_hooks.json`.
- MCP: `mcpServers` in settings.json (verified: `context7`, `ghost`; gortex removed 2026-07-18).
- Extensions: `~/.gemini/extensions/` exists (verified). VERIFY: extension format/loading details.
- Misc: `trustedFolders.json`, session retention 30d, antigravity profile dirs alongside. Subagent/slash-command support: VERIFY — not confirmed on this machine.

## Antigravity (`agy` / `antigravity`) — Google agentic IDE + CLI

- Binaries `antigravity` (IDE) and `agy` (CLI) from the llm-agents.nix flake. CLI: `agy -p "<prompt>"` non-interactive, `--model`, `--continue`, `--sandbox`, `agy models`, `agy plugin`.
- Agent home: `~/.gemini/antigravity/` — runtime state (conversations, brain, knowledge, context_state, browser_recordings) stays real/local; auth shares the Gemini `oauth_creds.json` (never touch).
- Context: `~/.gemini/antigravity/AGENTS.md` → `~/.agents/AGENTS.md`; also reads project `AGENTS.md` from the workspace.
- Skills: `~/.gemini/antigravity/skills` → `~/.agents/skills` (an old `.antigravity-install-manifest.json` from the gortex-skill install era lives in the pre-v2 backup).
- MCP: `~/.gemini/antigravity/mcp_config.json` — nix-managed symlink, currently `{"mcpServers": {}}` (gortex removed 2026-07-18; if antigravity supports per-workspace MCP config, prefer that for zenteiq — VERIFY).
- Knowledge items: `~/.gemini/antigravity/knowledge/` — antigravity's own memory store; the stale `gortex-workflow` item was moved to the 2026-07-18 backup.
- IDE app state: `~/.antigravity` (argv.json, extensions) and `~/.config/Antigravity` (Electron data) — machine-local, not nix-managed.

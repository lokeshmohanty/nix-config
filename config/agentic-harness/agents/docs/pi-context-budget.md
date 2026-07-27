# pi Context Budget — what startup context costs, and the lazy-tools fix

*Purpose: stop pi sessions from starting ~18k tokens deep. Numbers measured 2026-07-27 against pi 0.82.0.*

## How to measure (repeat this before changing anything)

```bash
pi -p --mode json --no-session --provider vllm-gemma4-31 --model google/gemma-4-31B-it "hi" \
  | python3 -c 'import sys,json
v=0
for l in sys.stdin:
    try: d=json.loads(l)
    except: continue
    if d.get("type")=="turn_end": v=d["message"]["usage"]["input"]
print(v)'
```

Ablate with `--no-context-files`, `--no-skills`, `--no-extensions`, `--no-tools`,
`--no-builtin-tools`. To ablate individual packages **without touching the live
config**, copy `~/.pi/agent/{settings,models,APPEND_SYSTEM,auth,trust}.*` into a
throwaway `$FAKE/.pi/agent/`, symlink `npm/node_modules`, `skills`, `agents`,
`extensions` back to the real ones, then run with `HOME=$FAKE`.

## Where the tokens went (2026-07-27, in `~/Documents/Research/Thesis`)

Baseline for the prompt `"hi"`: **17,796** (gemma-4-31B) / **20,877** (Qwen3.5-122B).
The gemma↔Qwen gap is tokenizer only — the content is identical.

| Source | Tokens | Share |
|---|---|---|
| Extension packages | 10,871 | 58% |
| Built-in tools | 2,975 | 16% |
| `AGENTS.md` / `CLAUDE.md` | 2,848 | 15% |
| Skills listing | 2,094 | 11% |

**Tool schemas were 74% of startup context** — the prose files the harness design
worries about were the small part. Per package (leave-one-out, perfectly additive):

| Package | Tokens |
|---|---|
| `pi-agent-browser-native` | 2,822 |
| `@zosmaai/pi-llm-wiki` | 2,744 |
| `@tintinweb/pi-subagents` | 2,694 |
| `pi-web-access` | 1,578 |
| `pi-codex-goal` | 742 |
| `pi-observational-memory` | 291 |
| `pi-rich-renderer`, `pi-image-tools` | 0 (no tools) |

## The fix: `lazy-tools`

`pi/agent/extensions/lazy-tools/index.ts`. Packages stay in `settings.json` — they
**must**, because `pi.setActiveTools()` can only activate tools that are already
registered, and pi cannot load a package mid-session. The extension instead drops
them from the *active* set on `session_start`, which keeps their schemas out of the
prompt, and registers one small `load_tools(groups)` loader that re-activates a
group additively. pi records the additive change and exposes the new definitions
before the next model request (`extensions.md` → "Dynamic Tool Loading").

Groups → package: `subagents`, `browser`, `wiki`, `web`, `goal`, `memory`.
`/load-tools <group...>` activates manually. `/load-tools` with no args opens a
`SettingsList` toggle in the TUI (Enter/Space flips a row, Esc closes) that can also
turn a group back **off**; outside the TUI it prints on/off status instead.

Turning a group off is a *subtraction* from the active set. That is only forbidden
inside a loader tool's own execution — pi uses "purely additive" as the
deferred-load signal — so the toggle does it from the command handler, the same
place `session_start` parks everything.

## The fix: `lazy-skills`

`pi/agent/extensions/lazy-skills/index.ts`. Skills are already progressive
disclosure (only name + description sit in the prompt), but the descriptions alone
are not cheap: 14 global skills = **5,668 of 12,427 prompt bytes (46%)** in a bare
directory, 2,094 tokens in `Thesis/`.

The extension keeps a pinned core (`PINNED` in the file — currently `harness-ops`,
`no-mistakes`, `verification-before-completion`) and parks the rest, rewriting the
`<available_skills>` block in `before_agent_start`. Parked skills are still listed
**by name** in a compact `<parked_skills>` element (~400 bytes) so the model can see
they exist and call `load_skills(names)` to get the description and `<location>` in
the tool result — immediately, without waiting for the next prompt rebuild.

Nothing is unregistered: `/skill:<name>` still works on a parked skill, as does
reading its `SKILL.md`. `/skills` opens the same toggle UI (with fuzzy search);
`/skills <name...>` loads by name.

**Result (measured 2026-07-28 in `~/.nix`):** 5,400 → **4,530** tokens (−16%,
−870). The pinned block is 1,452 bytes vs 5,668 for all 14.

Both extensions reset on `session_start` — toggles are per-session, so a new
session always starts lean. That is deliberate; persisting them would let startup
context silently grow back.

**Result:** 17,796 → **7,961** in `Thesis/` (−55%); 4,616 in a bare directory.
Removing the packages outright would give 7,989 — i.e. lazy-tools costs ~750 tokens
of loader and buys back every capability on demand.

Verified working on the weak 31B model: given a delegation task it called
`load_tools(["subagents"])` at 8,782 tokens, then used `Agent` correctly at 11,280.

## Caveats

- **Native deferred loading is Anthropic-4.5+/OpenAI-gpt-5.4+ only.** Local vLLM
  providers take the documented fallback path: the tools simply join the active
  list, invalidating the prompt prefix. Harmless locally, no caching to lose.
- **Deferring tools does not disable an extension's non-tool behaviour.** `llm-wiki`
  still prints its session notice and still runs per-turn recall; `observational-memory`
  still hooks events. Only their tool schemas leave the prompt.
- **Baseline is not the whole story.** In one real session a single `read` of
  `literature/data/triage_ledger.yaml` injected ~7k tokens — more than any package
  costs. Trimming startup context does not fix careless reads.

## Traps (verified against pi 0.82.0, 2026-07-28)

- **Never mutate `systemPromptOptions.skills`.** `ctx.getSystemPromptOptions()`
  returns pi's *live* array (`opts2.skills === opts.skills`), and splicing it hangs
  pi hard enough to need a kill — the docs' "same shape and mutability" does not
  mean it is yours to edit. Read it, then rewrite the prompt **string** via the
  `before_agent_start` return value. Filtering the returned array does not work
  either: the prompt for that turn is already built.
- **A *discovered* extension importing `@earendil-works/pi-tui` needs the package
  in `pi/agent/npm/package.json`.** With two such extensions and the package
  missing, pi deadlocks at startup — silently, exit 0, no error, every extension
  after it in load order never registers. One importer happens to resolve; the
  second is what hangs. Installed via `npm install --save --legacy-peer-deps
  @earendil-works/pi-tui@^0.82.0` (`pi-image-tools@1.4.0` still peer-pins ≤0.80;
  that peer is already unmet for `pi-coding-agent`, which is not installed at all).
  `SettingsList`/`Container`/`Text` live only in `pi-tui` — `pi-coding-agent`
  exports just the themes (`getSettingsListTheme`, `getSelectListTheme`).
  `pi/agent/npm/` is otherwise fully gitignored, so `package.json` is now tracked
  (`!package.json`) to make this dep reproducible. **On a fresh machine**, after pi
  has installed the `settings.json` packages, run
  `cd ~/.pi/agent/npm && npm install --legacy-peer-deps`.
- **Print/JSON mode swallows extension errors.** A broken extension looks exactly
  like a working one: no output, exit 0. Bisect by moving extension dirs aside, and
  verify registration by dumping `pi.getAllTools()` from a throwaway `-e` probe
  (slash commands run in `-p` mode without a model call, which makes this cheap).
- **`-e` extensions load after discovered ones.** A `before_agent_start` probe
  loaded with `-e` sees the prompt *before* a discovered extension rewrites it. To
  see what is actually sent, hook `before_provider_request` and read
  `event.payload.system`.

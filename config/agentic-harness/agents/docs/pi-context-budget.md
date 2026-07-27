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
`/load-tools` with no args prints on/off status; with args it activates manually.

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

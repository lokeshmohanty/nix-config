# New pi capability: a command + a CLI, not a registered tool

*2026-08-09. Lokesh, mid-build, on a screen-recording extension that had just
registered two tools (`screen_record`, `video_convert`) and parked them behind
`lazy-tools`:*

> "I don't want it as a part of system prompt, rather add /record command which
> can take my input and do it as a subagent instead"

**The rule:** when adding a capability to pi, default to
**slash command → `pi-agent` subagent → CLI**, not a registered tool. Register a
tool only when the *main* model must call it mid-turn as part of its own
reasoning.

**Why:** a tool's schema is charged to every session's system prompt whether or
not the capability ever comes up; a command costs nothing until it is typed
(`pi-simplify` is the precedent — commands add no schemas). Deferring with
`lazy-tools` is *not* an answer here: it was written for heavy packages that the
main model genuinely needs to call, and it still leaves the loader and the
parking machinery in play. Asking me first would have skipped a full build:
I had already written, tested and wired both tools before he corrected it.

**How to apply:**
- Put the real capability in an AXI CLI under `agentic-harness/bin/` (see
  `axi-standards`). That is the single source of truth, usable by hand, by
  Claude over Bash, and by any subagent — and it costs no context anywhere.
- The extension stays thin: one `pi.registerCommand`, which shells out to
  `pi-agent <agent> "<task>"` with the user's request **verbatim** plus a brief
  that *points at the CLI* (`run it with no arguments; use `<cmd> --help`)
  rather than restating its flags — otherwise the brief drifts from the CLI.
- Dispatch detached (callback → `pi.sendMessage({display:true})`), never
  awaited in the handler: a worker takes minutes on this model and would freeze
  the TUI. Verified 2026-08-09: a trivial task took >6 min.
- On worker failure report the exit reason + a stderr tail, never `err.message`
  — execFile puts the whole task prompt in it.
- Bare `/<command>` (no argument) should print live state, not dispatch.

Worked example: `pi/agent/extensions/screen-recorder/` + `bin/screen-rec`,
documented in `agents/docs/harnesses.md` and `agents/docs/tools.md`. Test
extensions without pi by stubbing `ExtensionAPI` and running under
`node --experimental-strip-types` — same trick as
[[pi-rich-renderer-fork]]; note module resolution is relative to the *extension
file*, so a copy next to `node_modules` is the way to import it.

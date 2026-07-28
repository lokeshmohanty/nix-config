# pi-rich-renderer is a vendored fork (2026-07-28)

`~/.pi/agent/extensions/rich-renderer/` is a fork of the npm package
`pi-rich-renderer@0.1.0` (dbydd, MIT). The upstream package was removed from
`pi/agent/settings.json` `packages` **and** from `pi/agent/npm/package.json` — if
both are active they render the same message twice.

Extensions in `pi/agent/extensions/` are auto-discovered; they do not go in
`packages`. The fork imports `@earendil-works/pi-tui`, which is why that dep must
stay in `pi/agent/npm/package.json` (see the deadlock trap in
`~/.agents/docs/pi-context-budget.md`).

## Why the fork exists

Two upstream defects, both reproduced against pi 0.82.0 + ghostty 1.3.1.

**1. Aspect-ratio collapse.** Upstream passed both `maxWidthCells` and
`maxHeightCells` to pi-tui's `Image`, so `calculateImageCellSize()` took
`scale = min(widthScale, heightScale)` and rounded rows up with `ceil()`. A kitty
escape carrying both `c=` and `r=` is scaled to **fill** that box without
preserving aspect, so wide-short formula images were stretched vertically: a
995x41px formula became `c=56,r=2` — box aspect 14.0 against a natural 24.3 — and
rendered as an illegible smear. `richRenderer.imageScale: 0.5` halved it again
before the rounding, making it worse.

The fork derives **rows first** from the natural height, then computes columns
from the true aspect (`computeImageBox()`), and emits via `encodeKitty()` directly
instead of going through `Image`. Vertical rounding error was the killer — one
cell out of two is a 50% stretch, whereas one column out of ~56 is under 2%.
Same image now: `c=97,r=2` at `imageScale: 1.0`, aspect error 0.1%.

**2. Over-eager math matcher.** `\$[^\n$]+\$` and `\$\$[\s\S]*?\$\$` matched things
that are not maths, and because the extension *replaces* message content, a false
positive **deletes prose from the transcript**. Observed: a nix interpolation
(`${config.home.homeDirectory}/.gemini/.../AGENTS.md`) rendered as a LaTeX formula,
and an unbalanced `$$` paired with a later one to swallow whole paragraphs.

The fork protects inline code spans, refuses `${`, and gates every candidate
through `looksLikeMath()`: length cap, no blank lines, no path-like content, no
4-plus-word prose runs, and a positive requirement that something reads as maths.
That last gate matters — without it `$5 and $10` renders "5 and " as a formula.

## Testing it

The pure functions (`computeImageBox`, `looksLikeMath`, `splitMarkdown`) are
exported for exactly this. They run under `node --experimental-strip-types` **only
if** the file stays strip-only-clean: no TS parameter properties, and
`import type { ... }` rather than `import { type ... }` for
`@earendil-works/pi-coding-agent`, which is not installed. Resolve pi-tui by
symlinking `node_modules -> ~/.pi/agent/npm/node_modules` next to the test.

## Not explained

The original report also showed raw base64 on screen. That was never reproduced:
ghostty consumes every escape variant (chunked, `q=2`, `C=1`, explicit `c`/`r`),
pi-tui's `Markdown` preserves a 12,959-char escape line intact, and the
no-capability fallback prints `[Image: ...]`, never base64. Probably an artifact of
copying the transcript out of the terminal. If it recurs, that is a fresh
investigation, not this fix.

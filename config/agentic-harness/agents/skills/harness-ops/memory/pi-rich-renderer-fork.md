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

**3. Image escapes inside list items spill raw base64.** pi-tui's `Markdown`
renders a top-level image line verbatim, but `renderList()` re-wraps item content
to `itemWidth` **first** — splitting the escape's single enormous base64 "word"
across several lines. Only the first line keeps the `\x1b_G` prefix, so the
terminal draws a partial image and prints the remaining chunks as visible base64.
Table cells do not spill but blow out the row grid.

Verified by rendering the same escape in five positions (pi-tui 0.82.1, width 120):
standalone block, inline with single newlines, mid-sentence, inside a `-` item,
inside a table cell — **only the list item spilled** (4 stray base64 lines). This
is structural: a line-oriented renderer cannot place a multi-cell image inside a
wrapped list item. `structuredRanges()` therefore leaves math inside list items,
list continuation lines, and table rows as LaTeX source.

This is the symptom originally reported as "base64 instead of images" and first
written off as a copy artifact — it is real, and this is its cause.

## Testing it

The pure functions (`computeImageBox`, `looksLikeMath`, `splitMarkdown`) are
exported for exactly this. They run under `node --experimental-strip-types` **only
if** the file stays strip-only-clean: no TS parameter properties, and
`import type { ... }` rather than `import { type ... }` for
`@earendil-works/pi-coding-agent`, which is not installed. Resolve pi-tui by
symlinking `node_modules -> ~/.pi/agent/npm/node_modules` next to the test.

## Ruled out along the way

Ghostty itself is fine: it consumes every escape variant (4-chunk transmission,
`q=2`, `C=1`, explicit `c`/`r`) — confirmed by drawing seven variants side by side.
pi's `detectCapabilities()` is also right to report `images: "kitty"` for
`TERM_PROGRAM=ghostty`. Do not chase the terminal or the protocol; the three bugs
above are all in the extension.

`pi --print` cannot validate geometry: `terminalWidth()` returns ~3 with no TUI, so
both upstream and the fork emit `c=1,r=1`. Verify geometry with the unit test or a
real interactive session.

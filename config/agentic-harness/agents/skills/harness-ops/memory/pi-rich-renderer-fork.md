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

**4. Refusing to render in lists/tables renders almost nothing.** The first
attempt at (3) simply left list/table math as source. That is too aggressive:
models write math-heavy answers as glossary bullets and comparison tables. A real
"Maxwell's equations" reply contained 22 inline formulas, **0 display blocks**, and
0 free-standing math lines — every formula sat in a list or table, so nothing
rendered at all.

The fix is kitty **Unicode placeholders** (`U=1`): transmit the PNG once
out-of-band on its own top-level line (pi-tui passes image lines through
unwrapped), then place it with one `U+10EEEE` character per cell carrying
row/column diacritics, coloured with the image id. The inline run is ~60x smaller
than the raw escape and contains no base64, so re-wrapping can never spill —
worst case a wrapped line splits the image. Inline math is scaled to one cell tall
(`inlineColumns()`), which is what an inline formula should look like anyway.

Escape hatch: `richRenderer.inlinePlaceholders: false` falls back to LaTeX source
for inline math, for terminals that speak the kitty protocol but not placeholders.

## "[Image: image/png WxH]" instead of a formula — not a renderer bug

pi decides image support **purely from environment variables**
(`KITTY_WINDOW_ID`, `TERM_PROGRAM`, `GHOSTTY_RESOURCES_DIR`, `TERM` containing
ghostty/kitty, `ITERM_SESSION_ID`, …). Launch pi where none are set — a plain
`TERM=xterm-256color`, a bare login shell, a terminal that does not advertise
itself — and `detectCapabilities()` returns `images: null`. Every image then
degrades to pi-tui's `imageFallback()` text, `[Image: image/png 150x69]`.

Diagnose by which artefact appears, they are three different failures:
- `[Image: image/png WxH]` → capability detection said no images (this section)
- raw base64 → an escape was word-wrapped (defect 3)
- squashed/illegible formula → geometry (defect 1)

Fix: `richRenderer.imageProtocol: "kitty"` forces the protocol via
`setCapabilities()` at extension load, overriding detection for the whole TUI.
Only set it for a terminal that really does support the protocol.

## FIX 5/6/7 — placement, reserved rows, image ids (2026-07-29)

Three defects found by rendering a reply that mixes inline and display math. All
three are in the extension; kitty draws every escape correctly (3/3, above).

**5. A raw escape must never share a line with prose.** `encodeKitty()` draws at
the cursor and deliberately does not advance it, so any text after it on the same
line is printed *on top of the image*. Wrapping the escape in bare `\n` does not
help: markdown treats a single newline as a soft break, and the escape plus the
rest of the sentence come back as one line. Blank lines on both sides fix it.
So "block" now means **the formula owns its whole line** — `isStandaloneMath()` —
or carries display delimiters (`$$…$$`, `\[…\]`, `\begin{equation}`), which claim
one: `isDisplayDelimited()`. Everything else flows as placeholders, which occupy
real cells and cannot be overprinted. Display delimiters are promoted even
mid-sentence, because an integral squeezed into the single row inline placement
allows is illegible.

**6. Reserved rows do not survive markdown.** The blank lines that reserve an
image's height are collapsed — markdown emits at most one. A five-row block was
therefore drawn over by the next paragraph. Invisible while `imageScale` defaulted
to 0.5 and blocks were two rows; obvious once it became 1.0.
`getKittyImageReservedRows()` counts following lines of **zero visible width**, so
`reserveRows()` emits `"\n\n\x1b[0m"` per two rows: a bare colour reset is
non-empty (markdown keeps the line) and zero-width (pi-tui counts it). Consecutive
reset lines get soft-joined back into one, hence the interleaved blank. Measured
for 1–20 rows: always enough, overshoots by at most two blank rows.

**7. Placeholder ids must not start at 1.** The terminal stores images per window
by id, so a counter restarting at 1 in every process makes the next pi session
overwrite the previous one's images — a formula already drawn in a table cell was
seen changing into a formula from the following run. Seeded randomly now.

**8. Formulas render in parallel now**, deduplicated, four at a time — it was a
serial `await` in the segment loop. Measured cold on sudarshan: 12 distinct
formulas take 4.9s (latex is CPU-bound, so the win over serial is modest), 0.01s
once cached.

Also: one transmission per distinct PNG per message (a formula repeated three
times sent three copies of the base64), and `\PreviewBorder` is 0pt everywhere —
padding is dead space inside the image, and markdown's blank line around a block
is spacing enough.

`richRenderer.imageScale` should stay at **1.0**: one image pixel row per cell
pixel row at `LATEX_DPI`. Below that, thin strokes — integral signs, fraction
bars, subscripts — break up under downsampling.

## Beyond math (2026-07-29)

- **`/math [on|off]`** toggles rendering for the session — bare `/math` flips it.
  Off means replies keep their LaTeX source, which is what you want when copying a
  formula out. Verified live: the command fires and the next reply stays as source.
- **Streaming pre-warm.** `message_update` fires per token; the handler renders
  every *complete* formula as it arrives, so `message_end` finds a warm cache
  instead of stalling the whole reply behind latex. Throttled to one rescan per 48
  new characters and deduplicated per source. It must take the theme from the
  event's `ctx` — the theme is part of the cache key, so prewarming with a
  different one fills the cache with entries `message_end` never reads.
- **Chemistry** via `mhchem` in the preamble: `$\ce{CH4 + 2O2 -> CO2 + 2H2O}$`
  renders. Free — texlive-full already ships the package.
- **Graphviz** ` ```dot ` / ` ```graphviz ` fences render through `dot -Tpng`,
  with node/edge/font colours forced to the theme's text colour on a transparent
  background (graphviz defaults to black, invisible on a dark theme). Mermaid is
  **not** wired up: `mmdc` needs a headless browser.

Behaviour change worth knowing: in a terminal *without* kitty graphics, inline math
now degrades to readable LaTeX source rather than pi-tui's `[Image: image/png WxH]`
text, because such math is an inline segment now. Display blocks still use the
`Image` fallback.

Considered and dropped: warming the cache on session resume. Restored messages keep
their *rendered* content in the session file, `message_end` does not re-fire for
them, so there is nothing to warm.

## Testing it

`index.test.ts` sits beside `index.ts` and covers all of the above. It needs
pi-tui on the resolution path, which the extension dir does not have — copy both
files somewhere with a `node_modules` symlink to `~/.pi/agent/npm/node_modules`
and run `node --experimental-strip-types index.test.ts`.

## Testing the pure functions

The pure functions (`computeImageBox`, `looksLikeMath`, `splitMarkdown`) are
exported for exactly this. They run under `node --experimental-strip-types` **only
if** the file stays strip-only-clean: no TS parameter properties, and
`import type { ... }` rather than `import { type ... }` for
`@earendil-works/pi-coding-agent`, which is not installed. Resolve pi-tui by
symlinking `node_modules -> ~/.pi/agent/npm/node_modules` next to the test.

## Ghostty drops placeholders in mixed streams (measured 2026-07-29)

Ghostty 1.3.1 is **not** reliable for this extension's output. Rendering identical
escape bytes in ghostty and kitty 0.46.2, three runs each, on sudarshan:

| case | ghostty | kitty |
|---|---|---|
| direct placement `a=T,c=20,r=3` | 3/3 | 3/3 |
| placeholders only (4 shapes, 1–3 rows, line-start and mid-line) | 3/3 | 3/3 |
| direct placement **+** placeholders in one stream | 1/3 | 3/3 |

In the mixed case ghostty silently dropped one placeholder placement per run — a
different one each run, so it is a race, not an unsupported shape. `q=2` suppresses
the error response, so the formula is simply absent. That mixed stream is exactly
what this extension emits: display math as a direct placement, inline math as
placeholders. Diagnose it as a fourth artefact alongside the three below —
*intermittently missing* images, with no fallback text and no base64.

Use kitty for pi. If ghostty must be used, `richRenderer.inlinePlaceholders: false`
avoids the mixing at the cost of LaTeX source for inline math.

## Ruled out along the way

Ghostty consumes every *direct placement* escape variant (4-chunk transmission,
`q=2`, `C=1`, explicit `c`/`r`) — confirmed by drawing seven variants side by side.
That is what "ghostty is fine" was based on; it does not extend to placeholders
mixed with direct placements (see the section above).
pi's `detectCapabilities()` is also right to report `images: "kitty"` for
`TERM_PROGRAM=ghostty`. Do not chase the terminal or the protocol; the three bugs
above are all in the extension.

`pi --print` cannot validate geometry: `terminalWidth()` returns ~3 with no TUI, so
both upstream and the fork emit `c=1,r=1`. Verify geometry with the unit test or a
real interactive session.

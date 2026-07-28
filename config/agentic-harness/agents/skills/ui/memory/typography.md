# Typography — the three type roles

Decided 2026-07-28, first applied to `lokeshmohanty.github.io`.

| Role | Face | Carries |
|---|---|---|
| Display | **Space Grotesk** | headings, wordmark, post titles — anything set once and read as a shape |
| Running text | **Nunito** | body copy, prose, list items, descriptions |
| Labels, run IDs, data | **Cascadia Code** | section eyebrows, dates, counts, tags, IDs, metrics, inline code, code blocks |

The third role is wider than "code". Anything that is *a value rather than a
sentence* — a date, a count, a run ID, a metric — goes mono, so tabular things
align and scan as data. Uppercase eyebrow labels belong here too, not on display.

## Stacks (Tailwind v4 `@theme`)

```css
--font-display: "Space Grotesk Variable", ui-sans-serif, system-ui, sans-serif;
--font-body:    "Nunito Variable", ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
--font-mono:    "Cascadia Code Variable", ui-monospace, "SFMono-Regular", Menlo, monospace;
```

Loaded from Fontsource variable packages (`@fontsource-variable/space-grotesk`,
`-/nunito`, `-/cascadia-code`), `@import`ed at the top of the main CSS file. Each
package ships one `@font-face` per subset behind a `unicode-range`, so a latin
page fetches only the latin file — the other ~60 woff2 files ship to the deploy
but are never downloaded. Also import `@fontsource-variable/nunito/wght-italic.css`:
the body face meets `<em>` often enough that synthesised obliques are visible.

## Two Tailwind v4 traps that silently drop a face

1. **`--default-mono-font-family` is not emitted from `--font-mono`.** Preflight
   styles `code, kbd, samp, pre` with
   `font-family: var(--default-mono-font-family, ui-monospace, …)`. Tailwind does
   not derive that variable from your `--font-mono`, so *every code block falls
   through to the fallback* while the theme block looks correct. Set it
   explicitly in `@theme`:
   ```css
   --default-mono-font-family: var(--font-mono);
   ```
   This is invisible when the old `--font-mono` also started with `ui-monospace`,
   which is exactly how it goes unnoticed for a long time.

2. **`--font-sans` still exists** and backs stray `font-sans` utilities plus the
   typography plugin's fallbacks. Point it at the body face (`--font-sans:
   var(--font-body)`) so it cannot diverge from what `body` actually uses.

## Verifying

Not from the stylesheet — from a loaded page:

```js
getComputedStyle(document.querySelector("h1")).fontFamily  // → Space Grotesk Variable
getComputedStyle(document.querySelector("code")).fontFamily // → Cascadia Code Variable
[...document.fonts].filter(f => f.status === "loaded").map(f => f.family)
```

On NixOS, Playwright's bundled chromium fails on `libnspr4.so`; launch with
`executablePath: "/run/current-system/sw/bin/google-chrome-stable"` instead.

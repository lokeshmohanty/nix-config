---
name: ui
description: >
  Visual and front-end design conventions that hold across Lokesh's projects —
  typography, type roles, font loading. Use when choosing or changing a typeface,
  wiring webfonts into a build, naming design tokens, styling headings, labels,
  code or data, or reviewing whether a UI change matches the house style.
---

# UI

House conventions for how things look. These are decisions already made — apply
them rather than re-deriving a type scale or picking a "nice" font per project.

## Working rules

1. **Type is assigned by role, not by mood.** Every project uses the three roles
   in `memory/typography.md`. A fourth face needs a reason.
2. **Name tokens after the role, not the classification.** `--font-display`,
   `--font-body`, `--font-mono` — never `--font-serif` holding a sans, which is
   how a stack drifts out of sync with its names.
3. **Self-host webfonts.** Fontsource variable packages, imported in CSS, so the
   build hashes and fingerprints them. No CDN link tags: they add a third-party
   request per visitor and break offline dev.
4. **Verify in a browser, not in the stylesheet.** Read `getComputedStyle(...)
   .fontFamily` on a real element and check `document.fonts` actually loaded the
   family. A correct-looking `@theme` block routinely fails to reach `code`.

## Memory

- `memory/typography.md` — the three type roles, the exact stacks, and the
  Tailwind v4 traps that silently drop a face.

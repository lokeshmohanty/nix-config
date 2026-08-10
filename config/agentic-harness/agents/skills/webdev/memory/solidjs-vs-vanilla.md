---
description: >-
  Why converting personal/games from raw HTML/CSS/JS to SolidJS was rejected
  (2026-08-10), and the reusable checklist for any framework-migration question.
metadata:
  type: decision
  tags: [solidjs, framework, migration, build-step, vanilla-js]
---

# SolidJS vs vanilla — the games repo verdict (2026-08-10)

**Verdict: do not convert.** Asked to weigh merits/demerits for
`~/Projects/personal/games` (4 canvas games + portal, 5,570 lines, zero deps,
no build step, deployed to GitHub Pages as raw files).

## The measurement that decided it

| Layer | Lines | Framework helps? |
|---|---|---|
| `lib/net.js`, `lib/qr.js`, `lib/qr-decode.js` | ~2,350 | No — pure logic, barely any DOM |
| Canvas game loops (4 games) | ~1,800 | No — `rAF` + `ctx` draw calls |
| `lib/lobby.js` + per-game HUD/overlay | ~900 | **Yes** |
| CSS + portal | ~500 | No |

Roughly **15%** of the code would benefit. That number, not taste, is the
argument.

## Genuine merits found

- `lib/lobby.js` is a hand-rolled reactive state machine — `stage.replaceChildren()`
  at 5 sites plus a manual `setStatus()` pub/sub, over host/guest/spectator ×
  connecting/connected/started. Exactly what fine-grained reactivity replaces,
  and the most bug-prone file in the repo.
- `draw-guess.html:492-536` rebuilds the whole HUD every tick (timer, score
  pills, word hint) via `replaceChildren()` + per-branch `.style.color` /
  `.style.textShadow`. Solid would touch one text node.
- Overlay/HUD/portal-link chrome is copy-pasted across four games.

## Demerits that outweighed them

1. **Breaks `file://`.** `lib/net.js:22` and `lib/lobby.js:20` both state the
   scripts are deliberately classic (not ESM) so `file://` works with no
   server, and `docs/index.md` lists `file://` as a *verified* way to play two
   peers locally. JSX needs a compiler and emits ESM, which browsers refuse
   over `file://` (opaque origin → CORS). Escapable only by bundling to an
   IIFE global — fighting the toolchain from day one.
2. **Build step vs `path: '.'` deploy.** `.github/workflows/deploy.yml` uploads
   the repository as-is. A framework forces a build job, a `dist/`, and
   `.gitignore` churn to serve four static pages.
3. **Contradicts the repo's thesis.** It hand-rolls a QR *encoder*, a QR
   *decoder* (892 lines) and a WebRTC mesh layer. Stopping the
   own-your-stack instinct at the DOM shell is arbitrary. (Not a
   no-third-party-services violation — Solid is compile-time, not a network
   service — but the same instinct.)
4. **`scripts/preview.mjs`** drives game HTML headless to record portal gifs;
   it would need to target build output, adding a stale-build failure mode to
   the gif pipeline.
5. Single-file games stop being single-file — `connect4.html` is currently one
   readable, shareable file.

## The counter-offer that was made instead

A ~40-line `lib/reactive.js` (`createSignal` / `createEffect`) plus extracting
the duplicated HUD/overlay into `lib/ui.js` as plain factory functions. That is
Solid's actual innovation; JSX is ergonomics on top and is the part that costs
the build.

## Reusable checklist

Before recommending any framework migration:

1. Split LOC into DOM chrome / render loop / pure logic. Quote the ratio.
2. Grep the repo and its docs for `file://`, "no build", "no dependencies",
   "single file" — stated constraints outrank general best practice.
3. Read the deploy workflow. `path: '.'` means the build step is a new moving
   part, not a free one.
4. Find scripts that consume source files directly (preview recorders, e2e,
   screenshot tools) — each is migration work nobody budgets for.
5. Ask whether the framework's *core idea* can be had without its *toolchain*.
6. Present the merits honestly and first; a recommendation that only lists
   costs reads as reflexive conservatism and gets discounted.

See also the `ui` skill for the visual conventions that survive either choice.

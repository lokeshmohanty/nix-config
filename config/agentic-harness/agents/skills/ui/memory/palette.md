# Palette — the instrument reading

Decided 2026-07-28 alongside [[typography]], first built in
`~/Documents/Research/Thesis/thesis-ui/src/app.css`. Dark palette shared
verbatim by `ecr` and `reticle` (Zola theme). Light palettes have diverged:

- **thesis-ui / reticle** — blueprint-cool paper (`#e7ecef`), the canonical
  light palette.
- **ecr** — near-white paper (`#fbfcfd`), warmer ink (`#12222a`), and slightly
  shifted accents (proved `#0f766e`, obligation `#5b46b8`, blocking `#b4382a`).
  Evolved independently for a mail client that is looked at all day.


The direction is *an instrument reading of a document*: a cool blueprint-paper
ground, petrol ink, and three semantic accents that carry meaning rather than
decoration.

## The three accents mean something

| Token | Meaning |
|---|---|
| `--proved` (teal) | proved, confirmed, cleared, done |
| `--obligation` (violet) | owed, awaiting judgement, in progress — **also the UI accent** |
| `--blocking` (red) | blocking. Used sparingly; it has to stay loud |

Never pick one of these for aesthetics. A violet button means "this is pending
your judgement"; a teal one means "this is settled". If a colour is needed with
no such meaning, use `--ink-*` or `--neutral-bg`.

## Tokens

```css
:root {
  --paper:      #e7ecef;  --paper-2:   #f6f9fa;  --card:      #fdfefe;
  --ink:        #0d1a22;  --ink-2:     #4a5c65;  --ink-3:     #7c8d95;
  --rule:       #c2d0d7;  --rule-soft: #d8e2e7;

  --proved:     #0e6b5e;  --proved-bg:     #dcece8;
  --obligation: #5340bb;  --obligation-bg: #e3e0f5;
  --blocking:   #a01c12;  --blocking-bg:   #f4dedb;
  --neutral-bg: #dde5e9;
  color-scheme: light;
}

@media (prefers-color-scheme: dark) {
  :root {
    --paper:      #0c151a;  --paper-2:   #111d24;  --card:      #14222a;
    --ink:        #e6eef1;  --ink-2:     #9fb2bb;  --ink-3:     #708590;
    --rule:       #2a3d47;  --rule-soft: #1e2e37;

    --proved:     #5fc9b6;  --proved-bg:     #10312d;
    --obligation: #a99bf5;  --obligation-bg: #241f47;
    --blocking:   #ef8377;  --blocking-bg:   #3b1a17;
    --neutral-bg: #1b2b33;
    color-scheme: dark;
  }
}
```

## Rules

1. **Name by role, never by hue** — `--ink-2`, not `--grey-600`. The dark
   palette rebinds every token; anything named for its colour becomes a lie.
2. **Three ink weights only.** `--ink` for text, `--ink-2` for secondary,
   `--ink-3` for labels and furniture. A fourth means the hierarchy is wrong.
3. **Two rules only.** `--rule` for real separation, `--rule-soft` for
   grouping inside a block.
4. **Surfaces stack `--paper` → `--paper-2` → `--card`.** Panels and rails sit
   on `--paper-2`; anything that should read as lifted uses `--card`.
5. **Focus rings use `--obligation`** — it is the interaction accent as well as
   the semantic one.

## Signature element

The **margin tape**: a 3px segmented rule down the left of a block whose colour
is the state of the thing beside it. It is what makes a list of items readable
as a status board without badges on every row.

```css
.tape { display: grid; grid-template-columns: 3px 1fr; }
.tape__rail { background: var(--rule-soft); }        /* neutral */
.tape__rail--proved { background: var(--proved); }
```

## One trap

Email and other embedded third-party HTML must **not** inherit a dark canvas.
Real mail is authored for white; forcing `--paper` under it gives dark-on-dark
text in a large share of messages. Render foreign HTML on `#ffffff` inside its
sandbox regardless of the surrounding theme.

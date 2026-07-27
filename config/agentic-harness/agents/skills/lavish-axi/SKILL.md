---
name: lavish-axi
description: Turn a generated HTML artifact into a local collaborative review surface where the human annotates elements, queues prompts, and sends feedback back to the agent. Use when a response is easier to understand as a rich or interactive page than as prose.
---

# Lavish AXI Skill

Turns an HTML artifact into a browser review surface the human can annotate, then feeds
their comments back to the agent.

## When to use
When the answer is easier to grasp as a rich page than as prose — plans, comparisons,
diagrams, tables, UI mocks, reports — and you want the human to review or annotate it
rather than just receive a file.

## Guidelines
- **Installed on PATH** by the `axi-tools` nix package (`~/.nix/pkgs/axi-tools`). Call
  `lavish-axi` directly — do NOT use `npx`.
- **Orient first**: bare `lavish-axi` prints active sessions, the artifact playbooks, and
  visual guidance. There is no session-start hook, so run it once before writing HTML.
- **Read the playbooks before writing HTML**: `lavish-axi playbook <id>` for each that
  applies. IDs: `diagram`, `table`, `comparison`, `plan`, `code`, `input`, `slides`. One
  artifact often combines several.
- **Artifact location**: write HTML under `.lavish/` in the working directory unless the
  user says otherwise. Local assets (images, CSS, fonts) must sit in the same directory
  and be referenced with **relative** paths — a leading `/` will not resolve.
- **Design direction**, in strict priority order: (1) what the user asked for; (2) the
  design system of the project the artifact is *about* (which may not be the cwd); (3)
  only if both come up empty, the Tailwind v4 browser runtime + DaisyUI v5 CDN snippet
  from `lavish-axi design`. State which of the three you used when you deliver.
- **Polling is foreground**: `lavish-axi poll <html-file>` long-polls and stays silent
  until the user sends feedback or ends the session. Never background it with `nohup`,
  `&`, or `disown`; use a harness-tracked background job or keep it in the foreground.
  If it dies, just re-run — queued feedback is never lost.
- **Do not reopen uninvited**: if the user ended the session from the browser, reopening
  requires `--reopen`, and only when they ask or something important needs their eyes.

## Command surface (verified against v0.1.43 `--help`)
| Command | What it does |
|---|---|
| `lavish-axi <html-file>` | Open or resume a review session (`--reopen` to override a user-ended one) |
| `lavish-axi poll <html-file>` | Wait for user feedback or browser-proven layout failures |
| `lavish-axi end <html-file>` | End the session as the agent (plain reopen still allowed later) |
| `lavish-axi export <html-file> [--out <path>]` | Portable single-file copy with local assets inlined |
| `lavish-axi share <html-file> [--password <pw>]` | Publish to the third-party ht-ml.app — **PUBLIC by default** |
| `lavish-axi stop` | Shut down the background server |
| `lavish-axi playbook <id>` | Focused guidance for one artifact type |
| `lavish-axi design` | CDN snippets + DaisyUI component reference |

**`share` publishes to a third-party host.** Confirm with the user before running it, and
pass `--password` unless they want the page world-readable.

## Examples
- Review a plan: write `.lavish/plan.html`, then `lavish-axi .lavish/plan.html`, then
  `lavish-axi poll .lavish/plan.html`
- Hand off a standalone copy: `lavish-axi export .lavish/plan.html --out ~/plan.html`

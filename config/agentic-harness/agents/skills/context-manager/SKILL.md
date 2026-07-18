---
name: context-manager
description: Use at the start of any non-trivial task (3+ steps, multi-file exploration, or research/synthesis) to decide what runs in main context vs a sub-agent, and which model tier each piece deserves. Keeps main context an index; work returns as summaries.
---

# Context Manager — recursive delegation + model routing

Two decisions before doing any sizeable work: **where it runs** (main context vs
sub-agent) and **what model tier** it deserves. Applied recursively: a sub-agent
managing a big task applies the same rules to its own subtasks.

## 1. Where it runs

Keep the main context an **index**: project memory, task state, decisions,
summaries. Anything that would flood it gets delegated.

Delegate to a sub-agent (Agent tool) when the work is:
- **Exploration** — searching/reading many files to answer one question
  (use Explore/gortex-search agents; you need the conclusion, not the file dumps);
- **Self-contained production** — drafting a document section, building a harness,
  running a sweep, verifying a build — anything whose intermediate steps don't
  inform later main-context decisions;
- **Parallelizable** — independent subtasks with no shared state.

Do NOT delegate when: the task needs context already loaded here and cheaper to use
than re-derive; it's a quick 1–2 tool-call job; or it's a judgment call belonging to
the user (escalate instead).

### Sub-agent brief (the contract)

Every dispatch states: (1) the goal and its acceptance criteria; (2) the minimal
input — exact file paths, relevant skill names to invoke, constraints — never
"figure out the repo"; (3) the required return: a **summary shaped for the parent's
next decision** (findings, artifacts written, open issues), not a transcript.
If a result will be needed again, have the sub-agent write it to a file and return
the path + three-line summary.

### Memory discipline (catalog pattern)

Any memory a project keeps follows: main memory = overall summary only → catalog
file, one line per entry → detail file per entry. Never inline detail into the main
memory. New durable knowledge goes into a skill's `memory/`; volatile state goes
into the project's STATUS file; main memory files stay stable.

## 2. Model routing

Set the Agent tool's `model` parameter on every dispatch:

| Tier | Model | Use for |
|---|---|---|
| **Very difficult** | `fable` | Creating powerful/reusable skills; theory and proofs; research direction and novelty judgment; anything whose output other models will reuse many times |
| **Mid-difficult** | `opus` | Setting up experiments and harnesses; substantial code; paper-section drafting; debugging with unclear cause; synthesis across many sources |
| **Routine** | `sonnet` | Well-specified edits; running procedures an existing skill fully describes; formatting; bookkeeping; broad file exploration |
| **Trivial/bulk** | `haiku` | Mass mechanical transforms; simple lookups |

Rules of thumb:
- **Fable is scarce** — spend it where the output is *leveraged* (a skill, a proof,
  a decision that shapes weeks of work), never on execution a skill already
  describes. The point of writing skills with Fable is that Sonnet-class models can
  then execute them with near-Fable results.
- When a task mixes tiers, split it: Fable/Opus designs and writes the skill or
  plan; Sonnet executes it in a sub-agent.
- If a lower-tier agent's output fails acceptance criteria once, retry with the
  next tier up rather than iterating at the same tier.
- Escalate to the user, not to a bigger model, when the blocker is a judgment call
  (relevance, quality, taste, scope).

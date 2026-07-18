---
name: systematic-debugging
description: Use when encountering any bug, test failure, build break, or unexpected behavior — before proposing a fix. Guides root-cause investigation: reproduce, isolate, hypothesize, verify, then fix at the source.
---

# Systematic Debugging

Random fixes waste time and create new bugs; quick patches mask underlying issues. Find the root cause before attempting any fix — a fix proposed before Phase 1 is complete is a guess, not a fix.

This applies to test failures, production bugs, build failures, performance problems, and integration issues. It applies especially when a "quick fix" seems obvious, when you're under time pressure, when previous fixes didn't work, or when you don't fully understand the issue. Systematic debugging is faster than guess-and-check thrashing, including for simple bugs.

Complete each phase before moving to the next.

## Phase 1: Root Cause Investigation

1. **Read error messages carefully.** Full stack traces, line numbers, file paths, error codes. They often contain the exact answer.
2. **Reproduce consistently.** Exact steps, every time. If it isn't reproducible, gather more data — don't guess.
3. **Check recent changes.** Git diff, recent commits, new dependencies, config changes, environmental differences.
4. **Instrument component boundaries.** In multi-component systems (CI → build → sign, API → service → DB), log what enters and exits each component, verify config/env propagation, run once, and read the evidence to identify *which layer* fails. Then investigate that layer.
5. **Trace data flow backward.** Where does the bad value originate? What called this with that value? Keep tracing up the call chain to the original trigger. Fix at the source, not where the error surfaces. (See [techniques.md](techniques.md).)

## Phase 2: Pattern Analysis

- Find similar *working* code in the same codebase.
- If following a reference implementation, read it completely — don't skim and adapt a half-understood pattern.
- List every difference between working and broken, however small. Don't assume "that can't matter."
- Identify what the broken code depends on: settings, config, environment, implicit assumptions.

## Phase 3: Hypothesis and Minimal Test

- State a single, specific hypothesis: "I think X is the root cause because Y."
- Test it with the smallest possible change. One variable at a time.
- Confirmed → Phase 4. Not confirmed → form a new hypothesis. Do not stack more changes on top.
- If you don't understand something, say so and investigate — don't pretend and patch.

## Phase 4: Implementation

1. **Create a failing test case first** — the simplest reproduction, automated if possible, a one-off script if not.
2. **Implement a single fix at the root cause.** No "while I'm here" improvements, no bundled refactoring.
3. **Verify:** the new test passes, no other tests broke, the original symptom is actually gone.
4. **If the fix doesn't work:** stop and count. Fewer than 3 attempts → return to Phase 1 with the new information. Three or more failed fixes → stop fixing; this is an architecture signal, not a failed hypothesis. Symptoms of that: each fix reveals new coupling elsewhere, fixes need "massive refactoring," each fix creates new symptoms. Question whether the pattern itself is sound and discuss with the user before attempt #4.
5. After fixing, consider adding validation at every layer the bad data passed through, so the bug becomes structurally impossible (see [techniques.md](techniques.md)).

## Red Flags — Stop and Return to Phase 1

If you catch yourself thinking any of these, the process has been skipped:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand it, but this might work"
- Changing multiple things at once, then running tests
- Skipping the failing test ("I'll verify manually")
- Proposing solutions before tracing the data flow
- "One more fix attempt" after two or more failures

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The issue is simple, I don't need the process" | Simple bugs have root causes too, and the process is fast for them. |
| "It's an emergency, no time" | Systematic debugging is faster than thrashing. |
| "Try this first, investigate if it fails" | The first fix sets the pattern. Do it right from the start. |
| "I'll write the test after confirming the fix" | The failing test is the confirmation. |
| "Multiple fixes at once saves time" | You can't isolate what worked, and you cause new bugs. |
| "The reference is long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I can see the problem" | Seeing a symptom is not understanding a cause. |
| "One more attempt" (after 2+ failures) | 3+ failures means the architecture is in question, not the tweak. |

## Quick Reference

| Phase | Activities | Done when |
|-------|-----------|-----------|
| 1. Root cause | Read errors, reproduce, check changes, instrument, trace | You understand what breaks and why |
| 2. Pattern | Find working examples, compare completely | Differences identified |
| 3. Hypothesis | One specific theory, minimal test | Confirmed (or new hypothesis formed) |
| 4. Implementation | Failing test, single fix at source, verify | Bug gone, tests pass |

## When Investigation Finds No Root Cause

If the issue is genuinely environmental, timing-dependent, or external: document what you investigated, implement appropriate handling (retry, timeout, clear error), and add logging for the next occurrence. But most "no root cause" conclusions are incomplete investigations — check before settling there.

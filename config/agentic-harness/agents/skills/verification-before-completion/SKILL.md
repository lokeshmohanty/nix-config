---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — before committing, opening a PR, or reporting success. Requires running the verification command and reading its output first; evidence before assertions.
---

# Verification Before Completion

Claiming work is complete without verifying it is dishonesty, not efficiency. The rule: **no completion claim without fresh verification evidence.** If you haven't run the verification command *now, for this state of the code*, you cannot claim it passes. This covers paraphrases and implications too — "should work," "looks good," and a cheerful "Done!" are all completion claims.

## The Gate

Before stating any status or expressing satisfaction:

1. **Identify** — what command or check proves this claim?
2. **Run** — execute the full command, fresh and complete (not a stale or partial run).
3. **Read** — the whole output: exit code, failure counts, warnings.
4. **Compare** — does the output actually confirm the claim? If not, report the real status with the evidence. If yes, make the claim *with* the evidence.

Skipping a step and asserting anyway is guessing dressed up as reporting.

## What Each Claim Requires

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Fresh test run: 0 failures | An earlier run, "should pass" |
| Linter/typecheck clean | Fresh run: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs "look good" |
| Bug fixed | Re-test the original symptom: gone | Code changed, fix assumed |
| Regression test works | Red-green verified (fails without fix, passes with) | Test passing once |
| Subagent/delegated task done | Inspect the actual diff/artifacts | The agent's own success report |
| Requirements met | Line-by-line checklist against the spec | "Tests pass" |

## Red Flags — Stop and Verify

- Writing "should", "probably", "seems to", "I'm confident"
- Expressing satisfaction ("Great!", "Perfect!", "All set") before running anything
- About to commit, push, or open a PR without a fresh check
- Trusting a subagent's or tool's success report without inspecting results
- Relying on a partial or stale verification
- Being tired and wanting the task over — exhaustion is not evidence

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "It should work now" | Run it. |
| "I'm confident" | Confidence is not evidence. |
| "Just this once" | No exceptions; that's how trust erodes. |
| "The linter passed" | The linter is not the compiler or the test suite. |
| "The agent said success" | Verify independently. |
| "A partial check is enough" | Partial proves nothing about the whole. |
| "I phrased it differently, so the rule doesn't apply" | The rule covers meaning, not wording. |

## Patterns

```
Tests:       run suite → see "34/34 passed" → then say "all tests pass"
Regression:  write test → passes → revert fix → must fail → restore → passes
Build:       run build → see exit 0 → then say "build passes"
Requirements: re-read the spec → checklist each item → report gaps or completion
Delegation:  agent reports success → check the diff → verify → report actual state
```

## When to Apply

Before any success or completion claim, any expression of satisfaction with the work, any commit, PR, or handoff, and before moving to the next task. Run the command. Read the output. Then claim the result.

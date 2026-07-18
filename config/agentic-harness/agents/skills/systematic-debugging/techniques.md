# Debugging Techniques

Condensed companions to systematic-debugging. Language-agnostic; examples are illustrative.

## Root-Cause Tracing

Bugs often surface deep in the call stack (file created in the wrong directory, database opened with the wrong path). Fixing where the error appears treats a symptom. Instead, trace backward to the original trigger:

1. **Observe the symptom.** e.g. `git init` failed in the source directory.
2. **Find the immediate cause.** The exact call that failed and its arguments.
3. **Ask what called it, with what value.** e.g. `cwd = ''` — an empty string resolving to the process working directory.
4. **Keep tracing up** one caller at a time until you find where the bad value was born (e.g. test fixture read before setup ran).
5. **Fix at the source.** Never only where the error surfaced.

When you can't trace by reading, add instrumentation *before* the dangerous operation: log the arguments, the working directory, relevant env vars, and a captured stack trace (`new Error().stack`, `traceback.format_stack()`, etc.). In tests, write to stderr — loggers may be suppressed. Run once, then grep the output.

To find which test pollutes shared state, bisect: run tests one at a time (or halves of the suite) until the first polluter appears.

## Defense-in-Depth Validation

After fixing a bad-data bug, one validation check feels sufficient — but other code paths, refactors, or mocks can bypass it. Add checks at every layer the data passes through, so the bug becomes structurally impossible:

1. **Entry point** — reject obviously invalid input at the API boundary (empty, nonexistent, wrong type).
2. **Business logic** — assert the data makes sense for this specific operation.
3. **Environment guards** — refuse dangerous operations in specific contexts (e.g. under test, refuse writes outside the temp directory).
4. **Debug instrumentation** — log context before the dangerous operation for forensics when the other layers fail.

Map every checkpoint the data flows through, add a check at each, then try to bypass layer 1 and confirm layer 2 catches it.

## Condition-Based Waiting

Flaky tests usually guess at timing with arbitrary sleeps; they pass on fast machines and fail under load. Wait for the actual condition instead:

```
# Before: guessing
sleep(0.05); assert result is not None

# After: waiting for the condition
wait_for(lambda: result is not None, "result produced", timeout=5)
```

A generic `wait_for` polls the condition every ~10 ms and raises a descriptive error on timeout. Rules:

- Always include a timeout with a clear message — never loop forever.
- Read fresh state inside the loop; don't cache before it.
- Poll at ~10 ms, not every tick (wastes CPU) and not every second (slow tests).

An arbitrary delay is only correct when testing genuinely timed behavior (debounce, throttle): first wait for the triggering condition, then sleep a duration derived from known timing, with a comment explaining why.

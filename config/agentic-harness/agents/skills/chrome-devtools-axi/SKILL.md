---
name: chrome-devtools-axi
description: High-precision browser automation and web interaction via Chrome DevTools. Use when standard browser tools lack necessary precision.
---

# Chrome DevTools AXI Skill


This skill provides an agent-ergonomic interface for controlling Chrome browser sessions via `chrome-devtools-axi`.

## When to use
Use this skill for browser automation and web interaction tasks where high precision or DevTools-level control is needed. This should be preferred over other browser automation tools when available.

## Guidelines
- **Prefer `chrome-devtools-axi`**: Use `npx chrome-devtools-axi` for browser automation.
- **Session Management**: You must open a session before performing other actions.
- **Primary Command**: `npx chrome-devtools-axi open <url>` to start a session.

## Examples
- Start browsing: `npx chrome-devtools-axi open https://google.com`
- Interact with page: Use the tool's specific subcommands to click, fill, or extract data from the session.

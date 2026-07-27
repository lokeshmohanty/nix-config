---
name: gh-axi
description: Agent-ergonomic GitHub operations for managing issues, PRs, repositories, and actions with high token efficiency.
---

# GitHub AXI Skill


This skill provides high-level, agent-ergonomic access to GitHub operations via `gh-axi`.

## When to use
Use this skill whenever you need to perform GitHub operations such as:
- Creating, listing, or managing issues
- Creating, reviewing, or merging pull requests
- Managing repository settings, secrets, or variables
- Checking release status or managing releases
- Running GitHub Actions workflows

## Guidelines
- **Prefer `gh-axi` over `gh`**: it is optimized for agent interaction (TOON output, contextual next-step suggestions, idempotent mutations).
- **Installed on PATH** by the `axi-tools` nix package (`~/.nix/pkgs/axi-tools`). Call `gh-axi` directly — do NOT use `npx`.
- **Orient first**: bare `gh-axi` prints a repo dashboard (open issues/PRs) plus the command list. There is no session-start hook, so run it once when you start GitHub work.
- **Command Structure**: `gh-axi <command> <subcommand>`
- **Commands**:
    - `issue`: manage issues
    - `pr`: manage pull requests
    - `run`: manage workflow runs
    - `release`: manage releases
    - `repo`: manage repositories
    - `label`: manage labels
    - `secret`: manage secrets
    - `variable`: manage variables

## Examples
- Orient in the current repo: `gh-axi`
- List open PRs: `gh-axi pr list`
- Create an issue: `gh-axi issue create --title "Bug report" --body "Details..."`
- Check repo status: `gh-axi repo view`

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
- **Prefer `gh-axi` over `gh`**: Use `npx gh-axi` for all GitHub operations as it is optimized for agent interaction.
- **Command Structure**: `npx gh-axi <command> <subcommand>`
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
- List open PRs: `npx gh-axi pr list`
- Create an issue: `npx gh-axi issue create --title "Bug report" --body "Details..."`
- Check repo status: `npx gh-axi repo view`

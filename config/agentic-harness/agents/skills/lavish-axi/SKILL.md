---
name: lavish-axi
description: Transform HTML artifacts into collaborative review surfaces for human annotation and iterative refinement.
---

# Lavish AXI Skill


This skill allows the agent to turn generated HTML artifacts into collaborative review surfaces via `lavish-axi`.

## When to use
Use this skill when you have generated HTML artifacts (such as UI mocks, dashboards, or documentation) and need a human to review, annotate, or provide feedback on them. Instead of just providing a file, use `lavish-axi` to create a reviewable surface.

## Guidelines
- **Collaborative Review**: Use `lavish-axi` to enable humans to annotate and comment directly on the HTML content.
- **Feedback Loop**: Use the tool to send feedback back to the agent for iterative refinement of the artifact.
- **Execution**: Use `npx lavish-axi` to initiate the review surface.

## Examples
- Transform an HTML file into a review surface: `npx lavish-axi review <path_to_html_file>`
- Send a generated UI for human feedback: `npx lavish-axi publish <artifact_id>`

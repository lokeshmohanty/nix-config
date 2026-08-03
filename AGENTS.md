# ~/.nix — NixOS Configuration — Agent Index

> Minimal index. Read `STATUS.md` next for current state; full documentation in
> `docs/` (start at `docs/index.md`). Global harness rules: `~/.agents/AGENTS.md`.
> This repo is ALSO the canonical home of the agent harness itself
> (`config/agentic-harness/` — documented in `config/agentic-harness/agents/docs/`,
> change only via the `harness-ops` skill).

## What this is

Flake-based NixOS + home-manager configuration for Lokesh's machines
(hosts: `sudarshan` (main), `bhaskara`, `bose`). System modules, home modules,
app configs, custom packages, and the cross-harness agent setup — all applied
via `nixos-rebuild` / `home-manager switch` (see `docs/index.md` for commands).

## Map

| path | what |
|---|---|
| `flake.nix` + `variables.nix` | inputs (nixpkgs unstable, home-manager, hyprland/niri, stylix, llm-agents, …) + `config.vars.*` options |
| `hosts/` | per-host wiring (`sudarshan`, `bhaskara`, `bose`, `server.nix`) |
| `system/` | NixOS modules (DE, fonts, services, security, virtualisation, …) |
| `home/` | home-manager modules (`ai.nix` = agent tools, `activations.nix` = symlinks, editor/shell/gui, …) |
| `config/` | raw app configs symlinked by activations (hypr, niri, waybar, **agentic-harness**, …) |
| `pkgs/` | custom packages (nvim, ghost-*, axi-tools) |
| `scripts/` | user scripts, linked into `~/.local/bin` |
| `Justfile` | non-nix setup recipes (fish plugins, wallpapers, prompt) |
| `STATUS.md` | volatile: current focus, pending config chores |
| `docs/` | documentation: apply commands, architecture, conventions |

## Binding rules

1. Harness changes (`config/agentic-harness/`) go through the `harness-ops` skill
   and must update `config/agentic-harness/agents/docs/` in the same commit.
2. Activation symlinks use `ln -sfn` — never bare `ln -sf` onto an existing dir.
3. No secrets in this repo (API keys, tokens, credentials stay in machine-local
   files; see `config/agentic-harness/agents/docs/layout.md`).
4. After editing nix files: `nix-instantiate --parse` the file, then apply with
   the commands in `docs/index.md`; commit only after a successful switch.
5. Significant changes update `docs/` in the same session (`docs-sync` skill).

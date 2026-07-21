# Architecture — how the flake is wired

*Last verified: 2026-07-18 against the actual sources.*

## Flake shape (flake-parts)

`flake.nix` uses **flake-parts** (`mkFlake`), systems `x86_64-linux`. It imports
`./hosts` (which exports `nixosConfigurations` + `homeConfigurations`) and the
home-manager flake module. `perSystem` exposes `pkgs/` as flake packages + apps
and sets `nixfmt` as formatter.

Key inputs: nixpkgs (unstable), determinate, home-manager, hyprland, niri,
noctalia, stylix, nixos-hardware, musnix, **llm-agents (numtide — provides
claude-code, pi, codex, gemini-cli, qwen-code, antigravity)**, nix-alien,
plus non-flake nvim plugin pins (`plugins-*`).

## Hosts (`hosts/`)

`hosts/lib.nix` defines `hostlib.mkNixosHost { hardwareModules, extraModules }`
and `hostlib.mkHomeHost <module>`. Each host dir (`sudarshan`, `bhaskara`,
`bose`) declares both in its `default.nix`:

- **system**: `configuration.nix` + `hardware-configuration.nix` (+ host extras
  like `syncthing.nix`), hardware profile from nixos-hardware.
- **home** (`lokesh@<host>`): imports `../../home` (+ host extras like
  `email.nix`) and flips feature toggles:
  `modules = { ai.enable; activations.enable; editor.enable; gui.enable; shell.enable; tui.enable; }`.
- **Ubuntu/server home** (`lokesh@server`): imported from `hosts/server.nix`.
  It enables AI, editor, shell, TUI, and their activations while disabling GUI
  styling. `scripts/install.sh` applies this standalone Home Manager profile.

## Options pattern

- `variables.nix` → `options.vars.*`: `username` (lokesh by default),
  `homeDirectory`, `nixDir` (`~/.nix` — used by activations to point symlinks at
  the repo), and `fontName`.
- Feature modules declare `options.modules.<name>.enable = mkEnableOption` and
  gate their config with `lib.mkIf`. Hosts opt in per machine.
- `home/default.nix` imports every home module unconditionally plus defaults
  (stylix theme `everforest-dark-hard`, wallpaper).

## The two module trees

- `system/` — NixOS: desktop-environment, fonts, packages, programs, security,
  services, ssh, virtualisation, gaming.
- `home/` — home-manager: `base`, `ai` (installs agent CLIs from llm-agents),
  `activations` (**runtime symlinks guarded by their owning home feature: GUI
  configs by `modules.gui`, scripts by `modules.shell`, and agent-harness links
  by `modules.ai`; `modules.activations` is the master switch; `ln -sfn`
  mandatory**),
  `programs`, terminal/, browser/, email/, editor, shell, gui, stylix, xdg, etc.

## Agentic harness

`config/agentic-harness/` is the canonical cross-harness agent setup — a
self-documenting subtree. Do not modify it from this page's context; read
`config/agentic-harness/agents/docs/index.md` and use the `harness-ops` skill.

## Custom packages (`pkgs/`)

`pkgs/default.nix` maps each subdir (nvim, ghost-build/-charity/-wrapper,
oauthman) into flake packages and apps (`nix run ~/.nix#<name>`).

## Ubuntu bootstrap flow

`scripts/install.sh` is the supported non-NixOS entry point. It asks whether Nix
is required, then synchronizes a clean checkout at `$HOME/.nix` and follows one
of two paths:

- **Nix:** preserve or install Nix, resolve the Home Manager CLI from the locked
  flake, and switch `lokesh@server`. Installer-driven impure evaluation passes
  the validated login user, passwd home, and checkout path; pure evaluation
  retains the `lokesh` defaults. This path is currently x86_64-only and requires
  systemd when Nix must be installed.
- **APT:** enable Ubuntu universe, install the available server-tool subset, and
  link static Neovim/zk/scripts/agent-harness configs directly. It cannot render
  Home Manager shell/program settings or install Nix-only packages.

Unsupported hosts fail before configuration is changed.

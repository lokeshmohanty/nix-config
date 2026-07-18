# User Preferences

## OS-Level Dependencies (NixOS)
- I use NixOS and nix-flakes to manage OS-level dependencies
- OS-level dependencies are stored at `~/.nix`
- When I need system packages, prefer using nix-flakes or nix-shell

## Project-Level Dependencies
- **OS packages**: Use `shell.nix` at the project root for project-specific OS dependencies
- **Language-specific packages**: Use native package managers:
  - Python: `uv` (preferred) or `pip`
  - Node.js: `npm` or `pnpm`
  - Other languages: Their respective package managers

## General Guidelines
- Do not suggest installing OS packages via apt, dnf, or other system package managers
- For Python projects, prefer `uv` for dependency management and virtual environment creation
- For Node.js projects, ask whether I prefer `npm` or `pnpm` if unclear
- When setting up development environments, suggest `shell.nix` for OS deps + native package manager for language deps

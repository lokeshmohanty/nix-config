# Decisions

## 2026-07-21 — Narrow first Ubuntu installer contract

The first non-NixOS installer offers two explicit modes. Nix mode supports
Ubuntu on x86_64, with systemd required when Nix must be installed; it passes the
validated login user, home, and checkout path to `lokesh@server` during impure
evaluation. APT mode supports Ubuntu without adding the flake's architecture
restriction and installs only packages available from configured Ubuntu
repositories. Normal pure flake evaluation retains the existing `lokesh`
defaults.

The installer preserves an existing Nix installation and uses the Home Manager
package pinned by this repository. Existing checkouts must be clean and are only
fast-forwarded. This makes reruns predictable and avoids destructive recovery
behavior such as resetting or stashing. APT-mode config collisions are preserved
in a logged, timestamped backup tree before managed links replace them.

APT mode deliberately provides reduced equivalence. Home Manager-generated
settings, Nix-only AI tools, custom packages, and the wrapped Neovim dependency
closure are not replaced with unpinned third-party installers.

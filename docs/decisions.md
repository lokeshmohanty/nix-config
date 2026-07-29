# Decisions

## 2026-07-29 — kitty replaces foot as the default terminal

The niri session spawns a hidden kitty server at startup
(`kitty --single-instance --start-as=hidden`) and every launcher — `Mod+Return`,
`Mod+M`, the waybar `cpu`/`memory` click actions — uses `kitty --single-instance`,
which is served by that instance and returns immediately. This is the same
client/server shape the previous `foot --server` + `footclient` pair had, so
window environments are still inherited from the session at login, frozen there.

The driver is graphics. Both terminals implement the kitty graphics protocol, but
measured on this machine (kitty 0.46.2 vs ghostty 1.3.1, identical escape bytes,
three runs each): ghostty silently dropped one Unicode-placeholder placement in
two of three runs when direct placements and placeholder placements were mixed in
one stream — which is exactly what pi's `rich-renderer` emits (display math
direct, inline math via placeholders). `q=2` suppresses the error response, so a
dropped formula is invisible. kitty rendered all cases in three of three runs.
kitty also has `kitten @` remote control, already wired through
`allow_remote_control` + `listen_on` in `home/terminal/kitty.nix`, which ghostty
has no equivalent for; the agent harness can drive it.

`modules.gui.foot.enable` now defaults to false rather than being removed, so foot
is one line away if kitty misbehaves under niri. TERM stays kitty's default
`xterm-kitty`: pi detects image support from it, and `kitten ssh` handles terminfo
on remote hosts.

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

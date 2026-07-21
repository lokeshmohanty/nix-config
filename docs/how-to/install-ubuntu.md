# Install on Ubuntu

This installs the repository configuration on a fresh Ubuntu machine. It asks
whether to use Nix/Home Manager or install the Ubuntu-available subset with APT.

## Supported host

- Ubuntu. The Nix path currently requires `x86_64`; the APT path is not
  artificially architecture-restricted.
- Any normal login user whose `HOME` matches the account's passwd home.
- A normal non-root shell with `sudo` access when Nix or bootstrap packages
  need installation.
- A systemd-booted host when the Nix path must install Nix.

Other Linux distributions are deliberately rejected for now. ARM machines and
Nix-less containers without systemd can use only the APT path.

## Install

The reviewable two-step form is preferred:

```sh
git clone https://github.com/lokeshmohanty/nix.git ~/.nix
~/.nix/scripts/install.sh
```

The script can also be fetched directly; it still prompts through the terminal:

```sh
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/lokeshmohanty/nix/main/scripts/install.sh | bash
```

The installer first asks:

```text
Is Nix required on this system? [y/N]
```

- **Yes:** preserve a working Nix installation or install Determinate Nix, then
  apply `lokesh@server` with the Home Manager package pinned by `flake.lock`.
- **No/default:** enable Ubuntu universe, install OS-integrated packages with
  APT, install current release-sensitive tools from their official upstream
  installers into `~/.local/bin`, and link the static configuration.

For noninteractive use, pass `--with-nix` or `--without-nix`:

```sh
~/.nix/scripts/install.sh --without-nix
# Re-run upstream installers (otherwise existing user-local tools are reused)
~/.nix/scripts/install.sh --without-nix --update-tools
```

Equivalent Just recipes are available from the checkout:

```sh
just server-install-nix
just server-install-apt
```

In both modes the installer:

1. validates the operating system, user, and home directory, plus architecture
   when the Nix path is selected;
2. installs `curl` and `git` with APT if needed;
3. clones or fast-forwards the `main` branch at `~/.nix`;
4. follows the selected Nix or APT configuration path.

The script refuses dirty, divergent, wrong-branch, or unexpected-origin
checkouts. It never resets, stashes, or deletes local configuration changes.
In APT mode, conflicting config paths are moved to a timestamped directory under
`~/.local/state/lokesh-config/backups/` before links are created.

## APT-mode limits

APT mode keeps Ubuntu responsible for system-integrated dependencies such as
Python, ffmpeg, shells, mail/database clients, and desktop helpers. Fast-moving
CLIs are installed per-user from upstream: `uv` provides `jc`, `pre-commit`, and
`vdirsyncer`; official installers provide zoxide, just, direnv, fzf, yt-dlp,
Neovim, Node.js 22, and the configured AI CLIs (Gemini, pi, Qwen Code, Codex,
Claude Code, and Antigravity). Existing commands in `~/.local/bin` are reused;
pass `--update-tools` to refresh them. Ubuntu packages unavailable on a given
release are skipped with a warning.

APT mode cannot reproduce the wrapped Neovim plugin/LSP closure or Home
Manager-generated shell/program settings. AI authentication remains a separate
first-run step and is never performed by the installer.
The installer reports this rather than silently downloading unpinned binaries.

Warnings from unrelated third-party APT sources (expired keys, missing keys, or
duplicate source entries) belong to the host and are not rewritten by this
installer. If `apt-get update` completes using older indexes, installation can
continue; repair those repositories separately.

Log out and back in after the first installation so the new session environment
and PATH are fully loaded.

## Reapply or update

Keep the checkout clean, then run the same command:

```sh
~/.nix/scripts/install.sh
```

It asks for the mode again, fast-forwards `main`, and reapplies that path. Use a
mode flag to skip the prompt.

With Nix installed, the current server profile can be applied without invoking
the repository-syncing installer:

```sh
just server-switch
```

To update only the locked Home Manager input and immediately apply the result:

```sh
just server-update-home-manager
```

To apply an intentionally modified local checkout without fetching, use the
pinned Home Manager package directly instead of the installer:

```sh
export LOKESH_CONFIG_USER="$(id -un)"
export LOKESH_CONFIG_HOME="$HOME"
export LOKESH_CONFIG_DIR="$HOME/.nix"
hm_package=$(nix --extra-experimental-features 'nix-command flakes' \
  --accept-flake-config build --impure --no-link --print-out-paths \
  ~/.nix#homeConfigurations.\"lokesh@server\".config.programs.home-manager.package)
"$hm_package/bin/home-manager" --option accept-flake-config true \
  --option experimental-features 'nix-command flakes' \
  --impure switch --flake ~/.nix#lokesh@server
```

Do not run Home Manager with `sudo`; the profile belongs to the login user.

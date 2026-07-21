# Use current shell for all recipes
# set shell := ["fish", "-c"]

# Default command that lists all available commands
default:
    @just --list

# Install fish plugins (bass, autopair, tide) via fisher — no root or nix required
setup-fish:
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install jorgebucaran/autopair.fish
    fisher install edc/bass
    fisher install IlanCosman/tide@v6

setup-wallpapers:
    mkdir -p ~/Pictures
    git clone https://gitlab.com/lokeshmohanty/Wallpapers ~/Pictures/Wallpapers

# Set prompt for the "fish" shell using tide plugin
prompt:
    fish -c "tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Round --powerline_prompt_heads=Sharp --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Darkest --prompt_spacing=Sparse --icons='Few icons' --transient=No"

# Install the Ubuntu server profile with Nix and Home Manager
server-install-nix:
    ./scripts/install.sh --with-nix

# Install the Ubuntu server package/config subset without Nix
server-install-apt:
    ./scripts/install.sh --without-nix

# Resume APT installation with all tools and configurations, including fish,
# tmux, and Neovim; refresh existing upstream tools as well.
server-install-apt-full:
    ./scripts/install.sh --without-nix --all-packages --update-tools

# Apply the current lokesh@server Home Manager configuration
server-switch:
    #!/usr/bin/env bash
    set -Eeuo pipefail
    repo_dir="{{ justfile_directory() }}"
    export LOKESH_CONFIG_USER="$(id -un)"
    export LOKESH_CONFIG_HOME="$HOME"
    export LOKESH_CONFIG_DIR="$repo_dir"
    hm_package="$(nix --extra-experimental-features 'nix-command flakes' \
      --accept-flake-config build --impure --no-link --print-out-paths \
      "$repo_dir#homeConfigurations.\"lokesh@server\".config.programs.home-manager.package")"
    "$hm_package/bin/home-manager" \
      --option accept-flake-config true \
      --option experimental-features 'nix-command flakes' \
      --impure switch --flake "$repo_dir#lokesh@server"

# Update the Home Manager flake input, then apply lokesh@server
server-update-home-manager:
    nix flake update home-manager
    just server-switch

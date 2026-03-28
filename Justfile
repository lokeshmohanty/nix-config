# Use current shell for all recipes
set shell := ["fish", "-c"]

# Default command that lists all available commands
default:
  @just --list

# Install fish plugins (bass, autopair, tide) via fisher — no root or nix required
setup-fish:
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  fisher install jorgebucaran/autopair.fish
  fisher install edc/bass
  fisher install IlanCosman/tide@v6

# Set prompt for the "fish" shell using tide plugin
prompt:
  tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Round --powerline_prompt_heads=Sharp --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Darkest --prompt_spacing=Sparse --icons='Few icons' --transient=No

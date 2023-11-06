#!/usr/bin/env bash

# swww init & 
# swww img ~/.local/share/wallpapers/0001.jpg &
/nix/store/$(ls -la /nix/store | grep polkit-kde-agent | grep '^d' | awk '{print $9}')/libexec/polkit-kde-authentication-agent-1 & 
nm-applet --indicator &
# waybar &
# dunst &

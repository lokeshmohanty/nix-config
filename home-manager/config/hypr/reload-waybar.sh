#!/bin/sh

ps aux | awk '/waybar/ {print $2; exit}' | xargs kill; waybar &

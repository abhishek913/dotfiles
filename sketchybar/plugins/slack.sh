#!/bin/bash

# Reads Slack's Dock badge via lsappinfo. The badge is a number of unread
# DMs/mentions, or "•" when there are only unread channels.
source "$CONFIG_DIR/colors.sh"

BADGE=$(lsappinfo info -only StatusLabel "Slack" 2>/dev/null | sed -nE 's/.*"label"="([^"]*)".*/\1/p')

if [ -z "$BADGE" ]; then
  sketchybar --set $NAME drawing=off
elif [ "$BADGE" = "•" ]; then
  # only unread channels, no mentions: show the icon dimmed, no number
  sketchybar --set $NAME drawing=on label.drawing=off icon.color=$DIM
else
  sketchybar --set $NAME drawing=on label.drawing=on label="$BADGE" icon.color=$FG
fi

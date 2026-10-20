#!/bin/bash

# Triggered by `aerospace_workspace_change` (from exec-on-workspace-change in
# aerospace.toml) or by this item's own 5s poll. $NAME is space.<id>.
#
# Focus is read live rather than trusting $FOCUSED, which is empty on poll
# ticks. Plugins run as their own processes, so colors are sourced here.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"

SPACE_ID="${NAME#space.}"
FOCUSED_NOW=$(aerospace_with_timeout 2 aerospace list-workspaces --focused)
[ -z "$FOCUSED_NOW" ] && FOCUSED_NOW="$FOCUSED"
WINDOWS=$(aerospace_with_timeout 2 aerospace list-windows --workspace "$SPACE_ID" --count)
WINDOWS=${WINDOWS:-0}

if [ "$SPACE_ID" = "$FOCUSED_NOW" ]; then
  COLOR=$ACCENT_COLOR
elif [ "$WINDOWS" -gt 0 ] 2>/dev/null; then
  COLOR=$FG
else
  COLOR=$DIM
fi

# 1-5 are always there (like Omarchy's persistent workspaces); 6-9 appear
# only while in use.
if [ "$SPACE_ID" -le 5 ] || [ "$COLOR" != "$DIM" ]; then
  sketchybar --set "$NAME" drawing=on icon.color=$COLOR
else
  sketchybar --set "$NAME" drawing=off
fi

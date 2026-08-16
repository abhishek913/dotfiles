#!/bin/bash

# Triggered by the `aerospace_workspace_change` event (fired via
# exec-on-workspace-change in ~/.aerospace.toml), which sets $FOCUSED to
# $AEROSPACE_FOCUSED_WORKSPACE. $NAME is the space.<id> item invoking this.
#
# This runs as its own process spawned by the sketchybar daemon, so it does
# not inherit the color variables from sketchybarrc's shell -- source them.
source "$CONFIG_DIR/colors.sh"

SPACE_ID="${NAME#space.}"

if [ "$SPACE_ID" = "$FOCUSED" ]; then
  sketchybar --set $NAME icon.color=$BAR_COLOR background.color=$ACCENT_COLOR
else
  sketchybar --set $NAME icon.color=$WHITE background.color=$ITEM_BG_COLOR
fi

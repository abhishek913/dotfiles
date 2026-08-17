#!/bin/bash

# Triggered by the `aerospace_workspace_change` event (fired via
# exec-on-workspace-change in ~/.aerospace.toml), which sets $FOCUSED to
# $AEROSPACE_FOCUSED_WORKSPACE. $NAME is the space.<id> item invoking this.
#
# This runs as its own process spawned by the sketchybar daemon, so it does
# not inherit the color variables from sketchybarrc's shell -- source them.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"

SPACE_ID="${NAME#space.}"

if [ "$SPACE_ID" = "$FOCUSED" ]; then
  FG=$BAR_COLOR
  sketchybar --set $NAME icon.color=$FG background.color=$ACCENT_COLOR
else
  FG=$WHITE
  sketchybar --set $NAME icon.color=$FG background.color=$ITEM_BG_COLOR
fi

# One app-font icon per open window in this workspace -- same mapping
# front_app.sh uses, just run per app name instead of once.
ICON_STRIP=""
APPS=$(aerospace_with_timeout 2 aerospace list-windows --workspace "$SPACE_ID" --format "%{app-name}")
if [ -n "$APPS" ]; then
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    ICON_STRIP="$ICON_STRIP $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
  done <<< "$APPS"
fi

sketchybar --set $NAME label="$ICON_STRIP" label.color=$FG label.drawing=on

#!/bin/bash

# Triggered either by the `aerospace_workspace_change` event (fired via
# exec-on-workspace-change in ~/.aerospace.toml, which sets $FOCUSED to
# $AEROSPACE_FOCUSED_WORKSPACE) or by this item's own update_freq poll (which
# keeps the per-window app icons below fresh, but doesn't set $FOCUSED at
# all). $NAME is the space.<id> item invoking this.
#
# Highlight is decided from a live query rather than trusting $FOCUSED, since
# on a poll tick $FOCUSED is empty -- relying on it there de-highlighted the
# actually-focused space every few seconds.
#
# This runs as its own process spawned by the sketchybar daemon, so it does
# not inherit the color variables from sketchybarrc's shell -- source them.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"

SPACE_ID="${NAME#space.}"
CURRENT_FOCUSED=$(aerospace_with_timeout 2 aerospace list-workspaces --focused)
[ -z "$CURRENT_FOCUSED" ] && CURRENT_FOCUSED="$FOCUSED"

if [ "$SPACE_ID" = "$CURRENT_FOCUSED" ]; then
  FG=$ACCENT_COLOR
  sketchybar --set $NAME icon.color=$FG                \
                         background.drawing=on          \
                         background.color=$ACCENT_COLOR \
                         background.height=2             \
                         background.corner_radius=0      \
                         background.y_offset=-9
else
  FG=$WHITE
  sketchybar --set $NAME icon.color=$FG background.drawing=off
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

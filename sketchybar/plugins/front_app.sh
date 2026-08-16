#!/bin/sh

# Runs on the item's initial load, on a native macOS front-app switch, and
# on an AeroSpace workspace change -- the latter matters on multi-monitor
# setups, since focus can move to a different monitor without the
# frontmost app changing (e.g. two Ghostty windows, one per screen).
APP=$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)
[ -z "$APP" ] && APP="$INFO"

MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
if [ -n "$MONITOR_COUNT" ] && [ "$MONITOR_COUNT" -gt 1 ] 2>/dev/null; then
  MONITOR=$(aerospace list-monitors --focused 2>/dev/null | cut -d'|' -f1 | tr -d ' ')
  LABEL="$MONITOR  $APP"
else
  LABEL="$APP"
fi

sketchybar --set $NAME label="$LABEL" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$APP")"

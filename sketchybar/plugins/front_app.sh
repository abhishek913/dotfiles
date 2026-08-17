#!/bin/bash

# Runs on a native macOS front-app switch, and on an AeroSpace workspace
# change -- the latter matters on multi-monitor setups, since focus can
# move to a different monitor without the frontmost app changing (e.g. two
# Ghostty windows, one per screen).
#
# `aerospace` has been observed to occasionally take a while (or, on old
# versions, hang indefinitely) on a query rather than erroring -- bound
# every call so one slow/flaky invocation can never leave this item stuck.
# On timeout/failure this falls back to the macOS-native $INFO (from
# front_app_switched) or, failing that, leaves the item showing whatever it
# last had. See plugins/lib.sh.
source "$CONFIG_DIR/plugins/lib.sh"

APP=$(aerospace_with_timeout 2 aerospace list-windows --focused --format "%{app-name}")
[ -z "$APP" ] && APP="$INFO"
[ -z "$APP" ] && exit 0

MONITOR_COUNT=$(aerospace_with_timeout 2 aerospace list-monitors | wc -l | tr -d ' ')
if [ -n "$MONITOR_COUNT" ] && [ "$MONITOR_COUNT" -gt 1 ] 2>/dev/null; then
  MONITOR=$(aerospace_with_timeout 2 aerospace list-monitors --focused | cut -d'|' -f1 | tr -d ' ')
  [ -n "$MONITOR" ] && LABEL="$MONITOR  $APP" || LABEL="$APP"
else
  LABEL="$APP"
fi

sketchybar --set $NAME label="$LABEL" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$APP")"

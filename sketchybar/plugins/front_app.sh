#!/bin/bash

# Runs on a native macOS front-app switch, and on an AeroSpace workspace
# change -- the latter matters on multi-monitor setups, since focus can
# move to a different monitor without the frontmost app changing (e.g. two
# Ghostty windows, one per screen).
#
# `aerospace` (a beta CLI) has been observed to occasionally hang
# indefinitely on a query rather than erroring -- bound every call so one
# flaky invocation can never leave this item stuck. On timeout/failure this
# just falls back to the macOS-native $INFO (from front_app_switched) or,
# failing that, leaves the item showing whatever it last had.
aerospace_with_timeout() {
  local secs="$1"; shift
  local tmp; tmp=$(mktemp)
  ("$@" >"$tmp" 2>/dev/null) &
  local pid=$!
  ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid" 2>/dev/null
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  cat "$tmp"
  rm -f "$tmp"
}

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

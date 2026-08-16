#!/bin/bash

if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ] 2>/dev/null; then
    nowplaying-cli next
  else
    nowplaying-cli previous
  fi
  exit 0
fi

STATE="$(echo "$INFO" | jq -r '.state')"
if [ "$STATE" = "playing" ]; then
  MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
  sketchybar --set $NAME label="$MEDIA" drawing=on background.drawing=on
else
  sketchybar --set $NAME drawing=off
fi

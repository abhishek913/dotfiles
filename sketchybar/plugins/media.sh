#!/bin/bash

if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ] 2>/dev/null; then
    nowplaying-cli next
  else
    nowplaying-cli previous
  fi
  exit 0
fi

# Polled via update_freq rather than SketchyBar's built-in `media_change`
# event -- that event is deprecated as of macOS 26 and no longer fires
# reliably. `playbackRate` (0 = paused, >0 = playing) is more trustworthy
# than nowplaying-cli's own "state" field, which has been observed to
# return null even while something is actively playing.
INFO_JSON=$(nowplaying-cli get --json playbackRate title artist 2>/dev/null)
RATE=$(echo "$INFO_JSON" | jq -r '.playbackRate // 0' 2>/dev/null)
RATE_INT="${RATE%%.*}"

if [ -n "$RATE_INT" ] && [ "$RATE_INT" -gt 0 ] 2>/dev/null; then
  TITLE=$(echo "$INFO_JSON" | jq -r '.title // empty')
  ARTIST=$(echo "$INFO_JSON" | jq -r '.artist // empty')
  if [ -n "$ARTIST" ] && [ "$ARTIST" != "$TITLE" ]; then
    MEDIA="$TITLE - $ARTIST"
  else
    MEDIA="$TITLE"
  fi
  sketchybar --set $NAME label="$MEDIA" drawing=on background.drawing=on
else
  sketchybar --set $NAME drawing=off
fi

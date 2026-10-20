#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"
hover_label

if [ "$SENDER" = "mouse.scrolled" ]; then
  STEP=5
  CURRENT=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
  [ -z "$CURRENT" ] && exit 0
  if [ "$SCROLL_DELTA" -gt 0 ] 2>/dev/null; then
    NEW=$((CURRENT + STEP))
  else
    NEW=$((CURRENT - STEP))
  fi
  [ "$NEW" -gt 100 ] && NEW=100
  [ "$NEW" -lt 0 ] && NEW=0
  # Unmute on scroll, like most volume UIs.
  osascript -e "set volume output volume $NEW" -e "set volume without output muted" 2>/dev/null
  sketchybar --trigger volume_change INFO="$NEW"
  exit 0
fi

if [ "$SENDER" = "volume_change" ]; then
  MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null)
  if [ "$MUTED" = "true" ]; then
    sketchybar --set $NAME icon="󰝟" icon.color=$DIM label="muted" label.color=$DIM
  else
    VOLUME=$INFO
    case $VOLUME in
      [6-9][0-9]|100) ICON="󰕾" ;;
      [3-5][0-9])     ICON="󰖀" ;;
      [1-9]|[1-2][0-9]) ICON="󰕿" ;;
      *)              ICON="󰝟" ;;
    esac
    sketchybar --set $NAME icon="$ICON" icon.color=$FG label="$VOLUME%" label.color=$FG
  fi
fi

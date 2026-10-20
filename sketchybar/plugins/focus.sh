#!/bin/bash

# Focus timer state is just the end time (epoch seconds) in a file.
# `focus.sh toggle` (click) starts or stops it; plain runs (every 15s) update the label.
source "$CONFIG_DIR/colors.sh"

NAME="${NAME:-focus}"
STATE="${TMPDIR:-/tmp}/sketchybar_focus_end"
MINUTES=25
NOW=$(date +%s)

if [ "$1" = "toggle" ]; then
  if [ -f "$STATE" ]; then
    rm -f "$STATE"
  else
    echo $((NOW + MINUTES * 60)) > "$STATE"
  fi
fi

if [ ! -f "$STATE" ]; then
  sketchybar --set $NAME label.drawing=off icon.color=$DIM
  exit 0
fi

END=$(cat "$STATE")
LEFT=$(( (END - NOW + 59) / 60 ))

if [ "$LEFT" -le 0 ]; then
  rm -f "$STATE"
  sketchybar --set $NAME label.drawing=off icon.color=$DIM
  osascript -e 'display notification "Take a short break." with title "Focus block done" sound name "Glass"'
else
  sketchybar --set $NAME label.drawing=on label="${LEFT}m" label.color=$PEACH icon.color=$PEACH
fi

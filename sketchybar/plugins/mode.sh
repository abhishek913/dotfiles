#!/bin/bash

# $MODE comes from `sketchybar --trigger aerospace_mode_change MODE=<mode>`
source "$CONFIG_DIR/colors.sh"

if [ "$MODE" = "service" ]; then
  sketchybar --set $NAME drawing=on label="SERVICE"
else
  sketchybar --set $NAME drawing=off
fi

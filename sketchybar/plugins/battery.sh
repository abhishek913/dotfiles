#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"
hover_label

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')
[ -z "$PERCENTAGE" ] && exit 0

case ${PERCENTAGE} in
  9[0-9]|100) ICON="󰁹" ;;
  [7-8][0-9]) ICON="󰂂" ;;
  [5-6][0-9]) ICON="󰂀" ;;
  [3-4][0-9]) ICON="󰁾" ;;
  [1-2][0-9]) ICON="󰁼" ;;
  *)          ICON="󰂃" ;;
esac

COLOR=$FG
if [ -n "$CHARGING" ]; then
  ICON="󰂄"
elif [ "$PERCENTAGE" -le 20 ]; then
  COLOR=$RED
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="${PERCENTAGE}%" label.color=$COLOR

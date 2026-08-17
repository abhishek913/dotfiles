#!/bin/sh

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  9[0-9]|100) ICON="􀛨"
  ;;
  [6-8][0-9]) ICON="􀺸"
  ;;
  [3-5][0-9]) ICON="􀺶"
  ;;
  [1-2][0-9]) ICON="􀛩"
  ;;
  *) ICON="􀛪"
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
  LABEL_COLOR=$GREEN
elif [ "$PERCENTAGE" -le 20 ]; then
  LABEL_COLOR=$RED
else
  LABEL_COLOR=$TEAL
fi

sketchybar --set $NAME icon="$ICON" icon.color=$LABEL_COLOR label="${PERCENTAGE}%" label.color=$LABEL_COLOR

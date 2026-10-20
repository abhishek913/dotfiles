#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"
hover_label

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_PERCENT=$(ps -A -o %cpu | awk -v cores="$CORE_COUNT" 'NR>1 {s+=$1} END {printf "%.0f", s/cores}')

# Icon only, like Omarchy; it turns yellow/red under load, and the
# percentage shows on hover.
if [ "$CPU_PERCENT" -ge 80 ]; then
  COLOR=$RED
elif [ "$CPU_PERCENT" -ge 50 ]; then
  COLOR=$YELLOW
else
  COLOR=$FG
fi

sketchybar --set $NAME icon.color=$COLOR label="$CPU_PERCENT%" label.color=$COLOR

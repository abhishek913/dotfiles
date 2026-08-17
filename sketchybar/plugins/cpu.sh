#!/bin/bash

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")

CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

if [ "$CPU_PERCENT" -ge 80 ]; then
  LABEL_COLOR=$RED
  ICON="█"
elif [ "$CPU_PERCENT" -ge 50 ]; then
  LABEL_COLOR=$YELLOW
  ICON="▅"
else
  LABEL_COLOR=$WHITE
  ICON="▂"
fi

sketchybar --set $NAME icon="$ICON" label="$CPU_PERCENT%" label.color=$LABEL_COLOR icon.color=$LABEL_COLOR

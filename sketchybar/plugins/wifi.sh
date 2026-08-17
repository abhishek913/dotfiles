#!/bin/bash

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

# Wi-Fi device name varies by machine (usually en0, but not guaranteed) --
# resolve it from the hardware port list rather than hardcoding it.
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')

SSID=""
if [ -n "$WIFI_DEV" ]; then
  SSID=$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk -F' : ' '/^  SSID/{print $2}')
fi

if [ -n "$SSID" ]; then
  sketchybar --set $NAME drawing=on icon="📶" icon.color=$WHITE label="$SSID"
else
  sketchybar --set $NAME drawing=off
fi

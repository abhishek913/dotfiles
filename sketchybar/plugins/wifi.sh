#!/bin/bash

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

# Wi-Fi device name varies by machine (usually en0, but not guaranteed) --
# resolve it from the hardware port list rather than hardcoding it.
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')

# SSID lookup (ipconfig getsummary) returns "<redacted>" without location
# entitlements, so just show connected/disconnected via the icon instead.
CONNECTED=""
if [ -n "$WIFI_DEV" ]; then
  CONNECTED=$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null)
fi

if [ -n "$CONNECTED" ]; then
  sketchybar --set $NAME drawing=on icon="📶" icon.color=$SAPPHIRE label.drawing=off
else
  sketchybar --set $NAME drawing=off
fi

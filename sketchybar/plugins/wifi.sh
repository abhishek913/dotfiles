#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/lib.sh"
hover_label

# Wi-Fi device name varies by machine (usually en0) -- resolve it.
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')
IP=""
[ -n "$WIFI_DEV" ] && IP=$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null)

# SSID reads as "<redacted>" without location access, so hover shows the IP.
if [ -n "$IP" ]; then
  sketchybar --set $NAME icon="󰤨" icon.color=$FG label="$IP"
else
  sketchybar --set $NAME icon="󰤮" icon.color=$DIM label="offline"
fi

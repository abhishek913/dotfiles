#!/bin/bash

sketchybar --add item battery right \
           --set battery update_freq=120 \
                         label.drawing=off \
                         click_script='open "x-apple.systempreferences:com.apple.Battery-Settings.extension"' \
                         script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change mouse.entered mouse.exited

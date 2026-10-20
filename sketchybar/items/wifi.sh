#!/bin/bash

sketchybar --add item wifi right \
           --set wifi update_freq=15 \
                      label.drawing=off \
                      click_script='open "x-apple.systempreferences:com.apple.wifi-settings-extension"' \
                      script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi mouse.entered mouse.exited

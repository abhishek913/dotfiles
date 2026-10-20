#!/bin/bash

# Click opens btop in a new Ghostty window, like Omarchy's CPU module.
sketchybar --add item cpu right \
           --set cpu update_freq=3 \
                     icon="󰍛" \
                     label.drawing=off \
                     click_script="open -na Ghostty --args -e btop" \
                     script="$PLUGIN_DIR/cpu.sh" \
           --subscribe cpu mouse.entered mouse.exited

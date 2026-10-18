#!/bin/bash

# Focus timer. Click to start a 25-minute block, click again to stop.
# Shows minutes left while running; a notification fires when time is up.
sketchybar --add item focus right \
           --set focus icon=":clock:" \
                       icon.font="sketchybar-app-font:Regular:16.0" \
                       icon.color=$TEAL \
                       label.drawing=off \
                       update_freq=15 \
                       click_script="$PLUGIN_DIR/focus.sh toggle" \
                       script="$PLUGIN_DIR/focus.sh"

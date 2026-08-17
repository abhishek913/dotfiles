#!/bin/bash

sketchybar --add item meeting right \
           --set meeting icon=􀉉                 \
                         icon.color=$PEACH \
                         label.max_chars=28       \
                         update_freq=60           \
                         click_script="open -a Calendar" \
                         script="$PLUGIN_DIR/meeting.sh"

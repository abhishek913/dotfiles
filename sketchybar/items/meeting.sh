#!/bin/bash

# Next calendar event (hidden when there is none). Click joins the call.
sketchybar --add item meeting right \
           --set meeting icon="󰃰" \
                         icon.color=$DIM \
                         label.font="$FONT:Regular:12.0" \
                         label.max_chars=28 \
                         update_freq=60 \
                         click_script="open -a Calendar" \
                         script="$PLUGIN_DIR/meeting.sh"

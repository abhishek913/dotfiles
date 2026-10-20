#!/bin/bash

# Omarchy's clock: weekday and time. "q" = just left of the notch (or
# center-left on a display without one).
sketchybar --add item calendar q \
           --set calendar icon.drawing=off \
                          label.font="$FONT:Bold:12.0" \
                          label.padding_left=6 \
                          label.padding_right=6 \
                          update_freq=30 \
                          click_script="open -a Calendar" \
                          script="$PLUGIN_DIR/calendar.sh"

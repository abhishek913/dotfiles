#!/bin/bash

# Shows "SERVICE" while AeroSpace's service mode (alt-shift-;) is active.
# Hidden in normal mode. AeroSpace fires the event from its mode bindings.
sketchybar --add event aerospace_mode_change \
           --add item aerospace_mode left \
           --set aerospace_mode drawing=off \
                                icon.drawing=off \
                                label.color=$PEACH \
                                label.padding_left=8 \
                                script="$PLUGIN_DIR/mode.sh" \
           --subscribe aerospace_mode aerospace_mode_change

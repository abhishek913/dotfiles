#!/bin/bash

# Shows "SERVICE" while AeroSpace's service mode (alt-shift-;) is active, so
# it's obvious why the usual keys aren't doing what you expect. Hidden in
# normal mode. AeroSpace fires the event from its mode bindings in
# aerospace.toml (exec-and-forget sketchybar --trigger aerospace_mode_change).
sketchybar --add event aerospace_mode_change \
           --add item aerospace_mode left \
           --set aerospace_mode drawing=off \
                                icon.drawing=off \
                                label.color=$PEACH \
                                label.font="SF Pro:Bold:13.0" \
                                script="$PLUGIN_DIR/mode.sh" \
           --subscribe aerospace_mode aerospace_mode_change

#!/bin/bash

# Focused app name, dimmed so it doesn't compete with the workspaces.
sketchybar --add item front_app left \
           --set front_app icon.drawing=off \
                           label.color=$DIM \
                           label.font="$FONT:Regular:12.0" \
                           label.padding_left=10 \
                           script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched aerospace_workspace_change

# Deliberately no initial population call here: any `aerospace` CLI call
# from inside sketchybarrc's process tree can block on the Accessibility
# check and hang the whole bar. The first real event fills it in.

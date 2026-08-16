#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.color=$ACCENT_COLOR \
                                 icon.color=$BAR_COLOR \
                                 icon.font="sketchybar-app-font:Regular:16.0" \
                                 label.color=$BAR_COLOR \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched aerospace_workspace_change

# Deliberately no synchronous initial population call here (and no
# backgrounded one either -- it gets killed once sketchybarrc exits). Any
# `aerospace` CLI call made from inside sketchybarrc's own process tree can
# block on macOS's Accessibility permission check in a way that calls made
# from an interactive shell don't (TCC attributes the check to sketchybar
# itself as the "responsible process" here), which was hanging the entire
# bar's startup. The label populates within moments of the first real
# front_app_switched or aerospace_workspace_change event instead.

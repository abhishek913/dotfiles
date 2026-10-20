#!/bin/bash

# Slack's unread badge (the number on its Dock icon). Hidden when there's
# nothing unread or Slack isn't running. Click jumps to workspace 4.
sketchybar --add item slack right \
           --set slack drawing=off \
                       icon="󰒱" \
                       update_freq=10 \
                       click_script="source \"\$CONFIG_DIR/plugins/lib.sh\"; aerospace_with_timeout 3 aerospace workspace 4" \
                       script="$PLUGIN_DIR/slack.sh"

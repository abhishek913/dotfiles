#!/bin/bash

# Slack's unread badge (the number on its Dock icon), so you can keep Slack
# notifications muted and still see when something is waiting.
# Hidden when there's nothing unread or Slack isn't running.
# Clicking jumps to AeroSpace workspace 4, where Slack lives.
sketchybar --add item slack right \
           --set slack drawing=off \
                       icon=":slack:" \
                       icon.font="sketchybar-app-font:Regular:16.0" \
                       icon.color=$PINK \
                       label.color=$PINK \
                       update_freq=10 \
                       click_script="source \"\$CONFIG_DIR/plugins/lib.sh\"; aerospace_with_timeout 3 aerospace workspace 4" \
                       script="$PLUGIN_DIR/slack.sh"

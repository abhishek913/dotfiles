#!/bin/bash

# Omarchy's menu logo, Mac edition. Click opens Raycast (the launcher);
# right-click cycles to the next theme.
sketchybar --add item logo left \
           --set logo icon="" \
                      icon.font="$FONT:Regular:16.0" \
                      icon.color=$ACCENT_COLOR \
                      icon.padding_left=4 \
                      icon.padding_right=8 \
                      label.drawing=off \
                      click_script='[ "$BUTTON" = "right" ] && "$HOME/dotfiles/bin/theme" next >/dev/null || open -a Raycast'

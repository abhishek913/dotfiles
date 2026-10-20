#!/bin/bash

# AeroSpace workspaces as plain numbers, Omarchy-style: the focused one in
# the accent color, ones with windows in normal text, empty ones dimmed.
# 1-5 always show; 6-9 only appear while they have windows or focus.
#
# Workspace ids are a static list (matching the alt-1..alt-9 bindings), not
# queried from `aerospace list-workspaces` -- that call blocks until
# AeroSpace has Accessibility permission, which would hang sketchybarrc on a
# fresh install. See README.md.
WORKSPACES="1 2 3 4 5 6 7 8 9"

for sid in $WORKSPACES; do
  # No `space=$sid` property: that ties the item to a real macOS Space
  # (yabai's model) and made it render off-screen on secondary displays.
  sketchybar --add item space.$sid left                \
             --set space.$sid icon=$sid                \
                              icon.color=$DIM          \
                              icon.font="$FONT:Bold:13.0" \
                              icon.padding_left=5      \
                              icon.padding_right=5     \
                              label.drawing=off        \
                              update_freq=5            \
                              click_script="source \"\$CONFIG_DIR/plugins/lib.sh\"; aerospace_with_timeout 3 aerospace workspace $sid" \
                              script="$PLUGIN_DIR/space.sh" \
             --subscribe space.$sid aerospace_workspace_change
done

# The first aerospace_workspace_change event (or the 5s poll) sets the
# highlight; no `aerospace` query here for the same reason as above.

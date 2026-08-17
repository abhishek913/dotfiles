#!/bin/bash

# AeroSpace workspace switcher.
# Unlike yabai, AeroSpace has no native SketchyBar "space" item -- it drives
# updates via `exec-on-workspace-change` in ~/.aerospace.toml, which triggers
# the `aerospace_workspace_change` event below (see plugins/space.sh).
#
# Workspace ids are a static list (matching the alt-1..alt-9 bindings in
# ~/.aerospace.toml), not queried from `aerospace list-workspaces` --
# that call blocks indefinitely until AeroSpace has Accessibility permission,
# which would hang the whole sketchybarrc load on a fresh install.
WORKSPACES="1 2 3 4 5 6 7 8 9"

for sid in $WORKSPACES; do
  # NOTE: no `space=$sid` property here -- that ties visibility to a real
  # macOS Mission Control Space (yabai's model). AeroSpace's workspaces are
  # virtual and unrelated, and setting it made this item render off-screen
  # on secondary displays.
  # label shows one app-font icon per open window in this workspace (see
  # plugins/space.sh). AeroSpace has no "windows in workspace changed"
  # event like yabai's space_windows_change, so this is kept fresh by
  # update_freq polling in addition to the aerospace_workspace_change
  # subscription (which refreshes it instantly on every switch).
  sketchybar --add item space.$sid left                                    \
             --set space.$sid icon=$sid                                    \
                              icon.padding_left=8                          \
                              icon.padding_right=8                         \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.y_offset=-1                            \
                              background.drawing=on                        \
                              background.color=$ITEM_BG_COLOR              \
                              update_freq=5                                \
                              click_script="source \"\$CONFIG_DIR/plugins/lib.sh\"; aerospace_with_timeout 3 aerospace workspace $sid" \
                              script="$PLUGIN_DIR/space.sh"                \
             --subscribe space.$sid aerospace_workspace_change
done

sketchybar --add item space_separator left                             \
           --set space_separator icon="􀆊"                              \
                                 icon.color=$ACCENT_COLOR               \
                                 icon.padding_left=4                    \
                                 label.drawing=off                      \
                                 background.drawing=off

# NOTE: deliberately not querying `aerospace list-workspaces --focused` here
# to seed the initial highlight -- if AeroSpace hasn't been granted
# Accessibility permission yet, its CLI blocks forever waiting on the
# permission prompt, which would hang the whole sketchybarrc load. The first
# aerospace_workspace_change event (on the user's first workspace switch)
# fixes the highlight up within moments of startup.

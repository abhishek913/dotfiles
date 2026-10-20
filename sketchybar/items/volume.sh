#!/bin/bash

# Click toggles mute, scroll changes volume, hover shows the level.
sketchybar --add item volume right \
           --set volume label.drawing=off \
                        script="$PLUGIN_DIR/volume.sh" \
                        click_script="osascript -e 'set volume output muted (not (output muted of (get volume settings)))'; sketchybar --trigger volume_change INFO=\"\$(osascript -e 'output volume of (get volume settings)')\"" \
           --subscribe volume volume_change mouse.scrolled mouse.entered mouse.exited

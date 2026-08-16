#!/bin/bash

sketchybar --add item media e \
           --set media label.color=$ACCENT_COLOR \
                       label.max_chars=24 \
                       icon.padding_left=0 \
                       scroll_texts=on \
                       icon=􀑪             \
                       icon.color=$ACCENT_COLOR   \
                       background.drawing=off \
                       update_freq=3 \
                       click_script="nowplaying-cli togglePlayPause" \
                       script="$PLUGIN_DIR/media.sh" \
           --subscribe media mouse.scrolled

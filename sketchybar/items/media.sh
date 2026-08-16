#!/bin/bash

sketchybar --add item media_prev e \
           --set media_prev icon="⏮"          \
                            icon.color=$ACCENT_COLOR \
                            icon.padding_left=8      \
                            icon.padding_right=4     \
                            label.drawing=off        \
                            background.drawing=off   \
                            drawing=off              \
                            click_script="nowplaying-cli previous" \
           --add item media e \
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
           --subscribe media mouse.scrolled \
           --add item media_next e \
           --set media_next icon="⏭"          \
                            icon.color=$ACCENT_COLOR \
                            icon.padding_left=4      \
                            icon.padding_right=8     \
                            label.drawing=off        \
                            background.drawing=off   \
                            drawing=off              \
                            click_script="nowplaying-cli next"

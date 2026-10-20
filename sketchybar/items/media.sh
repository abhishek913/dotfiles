#!/bin/bash

# Now playing, right of the notch. Only visible while something plays.
sketchybar --add item media_prev e \
           --set media_prev icon="󰒮" \
                            icon.color=$DIM \
                            icon.padding_left=8 \
                            icon.padding_right=2 \
                            label.drawing=off \
                            drawing=off \
                            click_script="nowplaying-cli previous" \
           --add item media e \
           --set media icon="󰎈" \
                       icon.color=$ACCENT_COLOR \
                       icon.padding_left=4 \
                       label.color=$FG \
                       label.font="$FONT:Regular:12.0" \
                       label.max_chars=24 \
                       scroll_texts=on \
                       drawing=off \
                       update_freq=3 \
                       click_script="nowplaying-cli togglePlayPause" \
                       script="$PLUGIN_DIR/media.sh" \
           --subscribe media mouse.scrolled \
           --add item media_next e \
           --set media_next icon="󰒭" \
                            icon.color=$DIM \
                            icon.padding_left=2 \
                            icon.padding_right=8 \
                            label.drawing=off \
                            drawing=off \
                            click_script="nowplaying-cli next"

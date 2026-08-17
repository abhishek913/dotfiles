#!/bin/bash

sketchybar --add item wifi right \
           --set wifi update_freq=15 \
                      label.max_chars=18 \
                      script="$PLUGIN_DIR/wifi.sh"

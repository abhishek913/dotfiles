#!/bin/bash

# Open PRs waiting on your review (needs `gh auth login` once).
# Hidden when there are none, or when gh isn't installed/logged in.
sketchybar --add item github right \
           --set github drawing=off \
                        icon="" \
                        update_freq=300 \
                        click_script="open https://github.com/pulls/review-requested" \
                        script="$PLUGIN_DIR/github.sh" \
           --subscribe github system_woke

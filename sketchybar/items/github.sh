#!/bin/bash

# Number of open PRs waiting on your review (needs `gh auth login` once).
# Hidden when there are none, or when gh isn't installed/logged in.
sketchybar --add item github right \
           --set github drawing=off \
                        icon=":git_hub:" \
                        icon.font="sketchybar-app-font:Regular:16.0" \
                        icon.color=$MAUVE \
                        label.color=$MAUVE \
                        update_freq=300 \
                        click_script="open https://github.com/pulls/review-requested" \
                        script="$PLUGIN_DIR/github.sh" \
           --subscribe github system_woke

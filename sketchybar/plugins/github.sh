#!/bin/bash

# Counts open PRs where your review is requested. Runs every 5 minutes.
source "$CONFIG_DIR/colors.sh"

if ! command -v gh >/dev/null 2>&1; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

COUNT=$(gh search prs --review-requested=@me --state=open --json number --jq 'length' 2>/dev/null)

if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ] 2>/dev/null; then
  sketchybar --set $NAME drawing=on label="$COUNT"
else
  sketchybar --set $NAME drawing=off
fi

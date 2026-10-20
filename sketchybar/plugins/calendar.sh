#!/bin/bash

# Omarchy shows "Sunday 21:43"; this keeps 12-hour time.
sketchybar --set $NAME label="$(date +'%A %-I:%M %p')"

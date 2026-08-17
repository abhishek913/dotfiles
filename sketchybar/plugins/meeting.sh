#!/bin/bash

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

# Non-meeting calendars (birthdays/holidays/reminders) are excluded so they
# never show up as a "next meeting". Events are matched with `end date >=
# now` (not just start date) so an in-progress meeting still shows. Lives
# in its own .applescript file rather than a heredoc here -- a heredoc in
# this exact position (after the `source` above) reproducibly confused
# bash's own parser into misreading the script's line count, not an
# osascript problem.
RESULT=$(osascript "$CONFIG_DIR/plugins/meeting_query.applescript")

# Soonest-starting (or already-ongoing) event first.
NEXT=$(echo "$RESULT" | grep '|' | sort -t'|' -k2 -n | head -1)

if [ -z "$NEXT" ]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

TITLE=$(echo "$NEXT" | cut -d'|' -f1)
START_MIN=$(echo "$NEXT" | cut -d'|' -f2)
END_MIN=$(echo "$NEXT" | cut -d'|' -f3)
LOCATION_AND_NOTES=$(echo "$NEXT" | cut -d'|' -f4-)

if [ "$START_MIN" -le 0 ]; then
  LABEL="$TITLE (ends in ${END_MIN}m)"
  COLOR=$RED
elif [ "$START_MIN" -le 5 ]; then
  LABEL="$TITLE in ${START_MIN}m"
  COLOR=$RED
else
  LABEL="$TITLE in ${START_MIN}m"
  COLOR=$WHITE
fi

# Zoom/Meet/Teams/Webex link in the location or notes -> click joins the
# call directly. Otherwise falls back to opening Calendar.app.
LINK=$(echo "$LOCATION_AND_NOTES" | grep -oE 'https?://[a-zA-Z0-9._-]*(zoom\.us|meet\.google\.com|teams\.microsoft\.com|teams\.live\.com|webex\.com)[a-zA-Z0-9./?=_&%-]*' | head -1)

if [ -n "$LINK" ]; then
  sketchybar --set $NAME click_script="open \"$LINK\""
else
  sketchybar --set $NAME click_script="open -a Calendar"
fi

sketchybar --set $NAME drawing=on label="$LABEL" label.color=$COLOR

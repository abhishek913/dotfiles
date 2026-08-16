#!/bin/bash

# Runs as its own process spawned by the daemon -- source colors directly
# (see plugins/space.sh for why).
source "$CONFIG_DIR/colors.sh"

# Non-meeting calendars (birthdays/holidays/reminders) are excluded so they
# never show up as a "next meeting". Events are matched with `end date >=
# now` (not just start date) so an in-progress meeting still shows.
RESULT=$(osascript <<'APPLESCRIPT'
set output to ""
tell application "Calendar"
  set nowDate to current date
  set soon to nowDate + (12 * hours)
  repeat with cal in calendars
    set calName to name of cal
    if calName is not in {"Birthdays", "Holidays in Canada", "Canadian Holidays", "Siri Suggestions", "Scheduled Reminders"} then
      try
        set evts to (events of cal whose end date is greater than or equal to nowDate and start date is less than or equal to soon)
        repeat with e in evts
          set startMin to round (((start date of e) - nowDate) / 60)
          set endMin to round (((end date of e) - nowDate) / 60)
          set output to output & (summary of e) & "|" & startMin & "|" & endMin & "\n"
        end repeat
      end try
    end if
  end repeat
end tell
return output
APPLESCRIPT
)

# Soonest-starting (or already-ongoing) event first.
NEXT=$(echo "$RESULT" | grep '|' | sort -t'|' -k2 -n | head -1)

if [ -z "$NEXT" ]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

TITLE=$(echo "$NEXT" | cut -d'|' -f1)
START_MIN=$(echo "$NEXT" | cut -d'|' -f2)
END_MIN=$(echo "$NEXT" | cut -d'|' -f3)

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

sketchybar --set $NAME drawing=on label="$LABEL" label.color=$COLOR

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
          set evtLocation to ""
          set evtURL to ""
          set evtNotes to ""
          try
            set evtLocation to (location of e) as string
          end try
          try
            set evtURL to (url of e) as string
          end try
          try
            set evtNotes to (description of e) as string
          end try
          -- newlines in notes would break the one-event-per-line format below
          set AppleScript's text item delimiters to {return, linefeed}
          set evtNotes to (evtNotes's text items) as string
          set AppleScript's text item delimiters to ""
          set output to output & (summary of e) & "|" & startMin & "|" & endMin & "|" & evtLocation & " " & evtURL & " " & evtNotes & "\n"
        end repeat
      end try
    end if
  end repeat
end tell
return output

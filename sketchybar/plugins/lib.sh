# Shared helpers, sourced by plugin scripts and click_scripts. Not
# executable on its own.

# Runs a command with a hard wall-clock timeout so a flaky `aerospace` CLI
# call (see sketchybar/README.md's "Known quirk" section) can never leave a
# caller stuck. Prints the command's stdout; exits empty on timeout.
aerospace_with_timeout() {
  local secs="$1"; shift
  local tmp; tmp=$(mktemp)
  ("$@" >"$tmp" 2>/dev/null) &
  local pid=$!
  ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid" 2>/dev/null
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  cat "$tmp"
  rm -f "$tmp"
}

# Omarchy-style hover: icons sit alone in the bar and show their value only
# while the pointer is over them. Call at the top of a plugin; it handles
# the mouse events and exits, so the rest of the plugin only runs on real
# updates. Needs `--subscribe <item> mouse.entered mouse.exited`.
hover_label() {
  case "$SENDER" in
    mouse.entered) sketchybar --set "$NAME" label.drawing=on;  exit 0 ;;
    mouse.exited)  sketchybar --set "$NAME" label.drawing=off; exit 0 ;;
  esac
}

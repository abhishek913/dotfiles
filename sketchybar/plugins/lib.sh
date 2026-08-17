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

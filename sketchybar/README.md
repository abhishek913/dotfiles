# SketchyBar + AeroSpace

A custom macOS menu bar built with [SketchyBar](https://felixkratz.github.io/SketchyBar/),
in the style of [Josean Martinez's setup](https://github.com/josean-dev/dev-environment-files),
paired with [AeroSpace](https://nikitabobko.github.io/AeroSpace/) as the tiling
window manager. Themed **Catppuccin Mocha** to match `ghostty/` and `nvim/`.

## How it fits together

```
~/.aerospace.toml (symlink -> aerospace/aerospace.toml)
  workspace change
        |
        v
  exec-on-workspace-change hook
        |
        v
  `sketchybar --trigger aerospace_workspace_change FOCUSED=<id>`
        |
        v
~/.config/sketchybar (symlink -> sketchybar/)
  sketchybarrc  -- loaded once at startup, builds every bar item
  items/*.sh    -- one file per item, called by sketchybarrc to `--add` it
  plugins/*.sh  -- the script each item re-runs to refresh itself
```

SketchyBar and AeroSpace are two separate processes that don't know about each
other by default. The link between them is the `exec-on-workspace-change` line
in `aerospace.toml`, which fires a custom SketchyBar event
(`aerospace_workspace_change`) with the newly-focused workspace id every time
you switch. `plugins/space.sh` listens for that event and highlights the
matching `space.<id>` item.

This is why the workspace items in `items/spaces.sh` do **not** use
SketchyBar's built-in `--add space` / `space=<id>` item type — that only works
with yabai's native macOS Space integration. AeroSpace's workspaces are
virtual and unrelated to real macOS Spaces, so plain `--add item` is used
instead, driven entirely by the AeroSpace event above.

## File-by-file

| File | Purpose |
|---|---|
| `sketchybarrc` | Top-level config: bar appearance, item defaults, sources everything in `items/` |
| `colors.sh` | Catppuccin Mocha palette (`$BAR_COLOR`, `$ITEM_BG_COLOR`, `$ACCENT_COLOR`, `$WHITE`) |
| `items/spaces.sh` | Builds the workspace switcher (workspaces `1`-`9`, static list — see note below) |
| `items/front_app.sh` | Shows the focused monitor number (if 2+ displays) + focused app's name/icon |
| `items/media.sh` | Now-playing title/artist plus `media_prev`/`media_next` buttons (only visible while something is playing) |
| `items/meeting.sh` | Next upcoming/ongoing calendar event (only visible when one exists) |
| `items/wifi.sh` | Current Wi-Fi SSID (only visible while connected) |
| `items/calendar.sh`, `volume.sh`, `battery.sh`, `cpu.sh` | Self-explanatory right-side items |
| `plugins/lib.sh` | Shared `aerospace_with_timeout` helper (not executable on its own — sourced) |
| `plugins/space.sh` | Highlights the focused workspace on `aerospace_workspace_change` |
| `plugins/front_app.sh` | Updates on app switch or workspace change; queries AeroSpace directly for the focused window's app + monitor |
| `plugins/media.sh` | Polls `nowplaying-cli` every 3s; shows/hides `media`+`media_prev`+`media_next` together |
| `plugins/meeting.sh` | Runs `meeting_query.applescript`, formats the soonest event, sets a join-link `click_script` if found, hides the item if none |
| `plugins/meeting_query.applescript` | The actual Calendar.app query — kept as its own file, see note below |
| `plugins/wifi.sh` | Resolves the Wi-Fi hardware port and reads its SSID via `ipconfig getsummary` |
| `plugins/icon_map_fn.sh` | Bundle-id -> glyph lookup table (pulled from Josean's repo, app-agnostic) |
| `plugins/calendar.sh`, `volume.sh`, `battery.sh`, `cpu.sh` | Refresh scripts for those items |

**Note on `items/spaces.sh`:** the workspace list is a hardcoded `"1 2 3 4 5 6 7 8 9"`,
not the output of `aerospace list-workspaces --all`. That command blocks
indefinitely until AeroSpace has been granted Accessibility permission — if
`sketchybarrc` called it directly, a fresh install with permission not yet
granted would hang the entire bar at startup. Same reasoning kept an initial
`aerospace list-workspaces --focused` query out of the startup path; the
first workspace switch fixes up the highlight within moments.

**Note on `plugins/meeting_query.applescript`:** this used to be an inline
`osascript <<'APPLESCRIPT' ... APPLESCRIPT` heredoc directly in
`plugins/meeting.sh`. In that exact position (right after the `source
"$CONFIG_DIR/colors.sh"` line), it reproducibly made bash misread the
heredoc's extent and throw nonsensical downstream syntax errors — a bash
parsing quirk, not an AppleScript problem (the same script ran fine as a
standalone file). Moving it to its own file sidesteps the issue entirely
and is arguably cleaner anyway; prefer a separate `.applescript` file over
a heredoc if you add more AppleScript-driven plugins.

## Required one-time setup: Accessibility permission

AeroSpace needs **Accessibility** permission to control windows and answer
CLI queries (`aerospace workspace <n>`, `aerospace list-workspaces`, etc.).
Until it's granted, any `aerospace` CLI command — including SketchyBar's
`click_script="aerospace workspace $sid"` on each workspace button — hangs
rather than erroring.

Grant it once via:
```
System Settings > Privacy & Security > Accessibility > enable AeroSpace
```
(`open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"`
jumps straight there.)

## Multimedia & meetings

- `media` (with `media_prev`/`media_next` buttons flanking it) shows the
  current track's title/artist while something is playing, and the whole
  group disappears otherwise.
  - **⏮ / ⏭ buttons** skip to previous/next track (`nowplaying-cli
    previous`/`next`) — separate items in `items/media.sh`, always shown/
    hidden together with `media` by `plugins/media.sh`.
  - **Click** the title to toggle play/pause (`nowplaying-cli
    togglePlayPause`). **Scroll** on the title also skips tracks, as a bonus.
  - Polled every 3s (`update_freq=3`) via
    [`nowplaying-cli`](https://github.com/kirtan-shah/nowplaying-cli)
    (`brew install nowplaying-cli`) rather than SketchyBar's built-in
    `media_change` event — that event is **deprecated as of macOS 26** and
    was confirmed to never fire (a real YouTube video playing in Chrome
    never showed up through it). `playbackRate > 0` is used to detect
    playing rather than nowplaying-cli's own `state` field, which was
    observed returning `null` during confirmed-active playback. Sending
    playback commands (click/scroll) may not reliably reach every source —
    it's driven by the same MediaRemote framework macOS itself uses, so
    behavior follows whatever that source supports.
- `volume` **scroll up/down** raises/lowers system volume by 5% per notch
  (`osascript -e "set volume output volume ..."`), unmuting automatically if
  it was muted. **Click** toggles mute, showing `muted` in place of the
  percentage.
- `meeting` shows the next event across all real calendars (Birthdays,
  Holidays, Siri Suggestions, and Reminders are excluded) for the next 12
  hours: `Title in Nm` while upcoming, `Title (ends in Nm)` while in
  progress, turning red inside a 5-minute warning window. Hidden entirely
  when nothing's coming up. Refreshes every 60s (`update_freq=60` in
  `items/meeting.sh`) via `osascript` against Calendar.app — no extra
  permission grant was needed on this Mac, but if macOS ever prompts for
  Calendar/Automation access the first time it runs after a fresh install,
  allow it.
  - **Click** joins the call directly if the event's location or notes
    contain a Zoom/Google Meet/Teams/Webex link (regex match in
    `plugins/meeting.sh`, `click_script` is rewritten on every refresh).
    Falls back to opening Calendar.app when no link is found.
- `wifi` shows the current Wi-Fi network name, hidden when not connected.
  Reads it via `ipconfig getsummary <device>` (fast, no permission prompt)
  rather than the older `networksetup -getairportnetwork`, which returned
  "not associated" on this Mac even while genuinely connected. The Wi-Fi
  hardware port name is resolved dynamically (`networksetup
  -listallhardwareports`) rather than assuming `en0`, since that's not
  guaranteed across machines.

## Window borders (JankyBorders)

`~/dotfiles/borders/bordersrc` draws a colored border around the focused
window — the accent-color equivalent of the bar's own highlight, but for
whichever window has keyboard focus. It's a separate tool
([`felixkratz/formulae/borders`](https://github.com/FelixKratz/JankyBorders))
and a separate `brew services` entry from `sketchybar`, but shares the same
`sketchybar/colors.sh` palette (sourced directly) so a color change in one
place stays in sync everywhere. Inactive windows get no border
(`inactive_color=0x00000000`); only the focused one is highlighted.

```sh
brew services restart felixkratz/formulae/borders   # after editing bordersrc
```

## Multi-monitor

Verified working with two displays: every item (workspaces, front app,
calendar, volume, battery, cpu, meeting) renders identically on each
display's bar, since none of them are pinned to a specific display or macOS
Space. Clicking a workspace button on either screen's bar runs the same
`aerospace workspace <n>`. `front_app` prefixes the app name with the
AeroSpace monitor number (built-in is always `1`) whenever 2+ displays are
connected, and drops the prefix automatically back down to a single display
(e.g. clamshell mode) — see `plugins/front_app.sh`. `media` only appears
when something is actually playing, on whichever display shows the
notch-relative "e" position — that's expected, not a bug.

If you ever see an item rendering off-screen (bounding rect around
`-9999,-9999`) on a secondary display, check whether it has a `space=<id>`
property set — that ties visibility to a real macOS Mission Control Space,
which AeroSpace's virtual workspaces don't correspond to.

## Known quirk: `aerospace` calls can be slow when daemon-spawned

`aerospace` CLI calls made from inside a `sketchybar`-spawned child process
(a real event, not a manual `sketchybar --trigger`) have been observed to
be slower and less consistent than the exact same command run from an
interactive shell. On **AeroSpace 0.12.0** this manifested as a full
indefinite hang, every time, reproducibly. Upgrading to **0.21.3-Beta**
(which rewrote the client-server socket protocol -- see its release notes)
mostly fixed it: calls no longer hang forever, but still occasionally take
close to 2 seconds instead of the usual <1s. Root cause of the remaining
variance wasn't pinned down further. All `aerospace`-querying plugin code
(`plugins/front_app.sh`, `items/spaces.sh`'s `click_script`) goes through
`aerospace_with_timeout` in `plugins/lib.sh` — a hard wall-clock timeout so
a slow call degrades gracefully (blank/no-op once) instead of getting stuck.
Use the same helper for any new `aerospace`-querying plugin.

Keeping AeroSpace itself updated (`brew upgrade --cask aerospace`) is
worthwhile given how much this specific behavior improved across versions —
it's still beta software with frequent releases.

`aerospace.toml`'s `gaps.outer.top = 40` reserves space for the 37px bar so
AeroSpace's tiled windows don't extend underneath it — without this, e.g.
Chrome's tab strip/new-tab button ends up hidden behind the bar. Keep this
in sync if you ever change the bar's `height` in `sketchybarrc`.

`aerospace.toml` is on `config-version = 2` with an explicit
`persistent-workspaces` list matching the keybindings below — config-version
1 inferred persistent workspaces from keybindings automatically, but that's
deprecated as of AeroSpace 0.21. If you add/remove a workspace keybinding,
update `persistent-workspaces` to match.

## Useful commands

```sh
# Restart the bar after editing config (required — it doesn't hot-reload items/plugins)
brew services restart sketchybar

# Manual start/stop instead of the login service
brew services start sketchybar
brew services stop sketchybar

# Inspect a running item's current state (colors, position, script, etc.)
sketchybar --query <item-name>
sketchybar --query bar          # bar-level settings (height, color, sticky, ...)
sketchybar --query displays     # connected displays and their frames

# Logs (mainly useful if the bar isn't showing up at all)
tail -f /opt/homebrew/var/log/sketchybar/sketchybar.err.log

# AeroSpace: list/inspect (need Accessibility permission granted first;
# see "Known quirk" above re: occasional slowness from a daemon context)
aerospace list-workspaces --all
aerospace list-workspaces --focused
aerospace list-monitors
aerospace workspace <n>          # switch, same as alt-<n>
aerospace reload-config --dry-run --no-gui   # validate aerospace.toml without applying it

# Upgrade AeroSpace itself (beta, frequent releases, worth staying current)
brew upgrade --cask aerospace
```

### AeroSpace keybindings (from `aerospace.toml`)

| Keys | Action |
|---|---|
| `alt-1` .. `alt-9`, `alt-a`..`alt-z` | Switch to workspace |
| `alt-shift-1` .. `alt-shift-9` etc. | Move focused window to workspace |
| `alt-h/j/k/l` | Focus window left/down/up/right |
| `alt-shift-h/j/k/l` | Move window left/down/up/right |
| `alt-shift-minus` / `alt-shift-equal` | Resize smaller/larger |
| `alt-tab` | Workspace back-and-forth |
| `alt-shift-tab` | Move current workspace to the other monitor |
| `alt-slash` | Toggle tiles layout (horizontal/vertical) |
| `alt-comma` | Toggle accordion layout |
| `alt-shift-;` | Enter "service" mode (`esc` reload config, `f` toggle floating, `r` reset layout) |

Full command reference: https://nikitabobko.github.io/AeroSpace/commands

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
| `items/calendar.sh`, `volume.sh`, `battery.sh`, `cpu.sh` | Self-explanatory right-side items |
| `plugins/space.sh` | Highlights the focused workspace on `aerospace_workspace_change` |
| `plugins/front_app.sh` | Updates on app switch or workspace change; queries AeroSpace directly for the focused window's app + monitor |
| `plugins/media.sh` | Polls `nowplaying-cli` every 3s; shows/hides `media`+`media_prev`+`media_next` together |
| `plugins/meeting.sh` | Queries Calendar.app via `osascript`, formats the soonest event, hides the item if none |
| `plugins/icon_map_fn.sh` | Bundle-id -> glyph lookup table (pulled from Josean's repo, app-agnostic) |
| `plugins/calendar.sh`, `volume.sh`, `battery.sh`, `cpu.sh` | Refresh scripts for those items |

**Note on `items/spaces.sh`:** the workspace list is a hardcoded `"1 2 3 4 5 6 7 8 9"`,
not the output of `aerospace list-workspaces --all`. That command blocks
indefinitely until AeroSpace has been granted Accessibility permission — if
`sketchybarrc` called it directly, a fresh install with permission not yet
granted would hang the entire bar at startup. Same reasoning kept an initial
`aerospace list-workspaces --focused` query out of the startup path; the
first workspace switch fixes up the highlight within moments.

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
  when nothing's coming up. Click it to open Calendar.app. Refreshes every
  60s (`update_freq=60` in `items/meeting.sh`) via `osascript` against
  Calendar.app — no extra permission grant was needed on this Mac, but if
  macOS ever prompts for Calendar/Automation access the first time it runs
  after a fresh install, allow it.

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

## Known quirk: `aerospace` calls occasionally hang when daemon-spawned

The `aerospace` CLI (a beta tool) has been observed to occasionally hang
indefinitely on a query -- specifically when spawned as a child of the
`sketchybar` launchd service in response to a real event -- even though the
exact same command run from an interactive shell, or run standalone via
`sketchybar --trigger`, reliably returns in ~1s. Root cause wasn't pinned
down (tried: Accessibility permission, app restart, responsible-process
theory -- none fully explained the intermittency). `plugins/front_app.sh`
wraps every `aerospace` call in a 2-second timeout (`aerospace_with_timeout`)
so a stuck call can never leave the item permanently blank -- it just
degrades gracefully and catches up on the next successful event. If you add
more `aerospace`-querying plugins, use the same pattern rather than calling
`aerospace` directly.

`aerospace.toml`'s `gaps.outer.top = 40` reserves space for the 37px bar so
AeroSpace's tiled windows don't extend underneath it — without this, e.g.
Chrome's tab strip/new-tab button ends up hidden behind the bar. Keep this
in sync if you ever change the bar's `height` in `sketchybarrc`.

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

# AeroSpace: list/inspect (all block until Accessibility permission is granted)
aerospace list-workspaces --all
aerospace list-workspaces --focused
aerospace workspace <n>          # switch, same as alt-<n>
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

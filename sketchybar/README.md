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
| `items/front_app.sh` | Shows the focused app's name + icon |
| `items/media.sh` | Now-playing title/artist (only visible while something is playing) |
| `items/calendar.sh`, `volume.sh`, `battery.sh`, `cpu.sh` | Self-explanatory right-side items |
| `plugins/space.sh` | Highlights the focused workspace on `aerospace_workspace_change` |
| `plugins/front_app.sh` | Updates on `front_app_switched`, looks up an icon via `icon_map_fn.sh` |
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

## Multi-monitor

Verified working with two displays: every item (workspaces, front app,
calendar, volume, battery, cpu) renders identically on each display's bar,
since none of them are pinned to a specific display or macOS Space. Clicking
a workspace button on either screen's bar runs the same
`aerospace workspace <n>`. `media` only appears when something is actually
playing, on whichever display shows the notch-relative "e" position — that's
expected, not a bug.

If you ever see an item rendering off-screen (bounding rect around
`-9999,-9999`) on a secondary display, check whether it has a `space=<id>`
property set — that ties visibility to a real macOS Mission Control Space,
which AeroSpace's virtual workspaces don't correspond to.

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

#!/bin/bash

# Colors come from the active theme -- switch with `theme set <name>`
# (see bin/theme). ~/.config/theme/current points at ~/dotfiles/themes/<name>.
# Falls back to Tokyo Night (Omarchy's default) before a theme is chosen.
_THEME_COLORS="$HOME/.config/theme/current/colors.sh"
[ -f "$_THEME_COLORS" ] || _THEME_COLORS="$HOME/dotfiles/themes/tokyo-night/colors.sh"
source "$_THEME_COLORS"
unset _THEME_COLORS

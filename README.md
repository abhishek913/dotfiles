# dotfiles

Personal macOS setup: [Neovim](https://neovim.io) (via [LazyVim](https://www.lazyvim.org)), [Ghostty](https://ghostty.org), zsh with [Starship](https://starship.rs), [AeroSpace](https://nikitabobko.github.io/AeroSpace/), [SketchyBar](https://felixkratz.github.io/SketchyBar/), [JankyBorders](https://github.com/FelixKratz/JankyBorders), git, and [Claude Code](https://claude.com/claude-code). The desktop is styled after [Omarchy](https://omarchy.org) (thin solid bar, numbered workspaces, gapped tiling, accent window borders), with Omarchy-style themes you switch with one command.

## Setup: one command

Brand-new Mac (nothing installed, not even git):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishek913/dotfiles/main/install.sh)"
```

Mac that already has the repo:

```sh
bash ~/dotfiles/install.sh
```

`install.sh` does everything: installs Homebrew, clones this repo, installs every
package in the `Brewfile`, links all configs, applies the theme (Tokyo Night on first run),
asks for this machine's git name/email and GitHub login, installs Neovim plugins,
and starts SketchyBar, borders and AeroSpace. It's safe to re-run: links that are
already right are skipped, and any existing file it would replace is moved to
`<name>.bak.<timestamp>`. An existing `~/.zshrc` is kept as `~/.zshrc.local`.

The only thing it can't do for you: grant **Accessibility** to AeroSpace
(System Settings > Privacy & Security > Accessibility).

Optional: `bash ~/dotfiles/macos/defaults.sh` for keyboard, Dock and Finder settings.

**Work laptop?** Read [PERSONAL-VS-WORK.md](PERSONAL-VS-WORK.md) first. It's short.

## Layout

```
dotfiles/
├── install.sh       sets up / updates a Mac from this repo
├── Brewfile         every Homebrew package and app
├── zsh/             zshrc -> ~/.zshrc (machine-only bits in ~/.zshrc.local), aliases.zsh
├── starship/        starship.toml -> ~/.config/starship.toml
├── ghostty/         -> ~/.config/ghostty
├── nvim/            -> ~/.config/nvim
├── git/             gitconfig -> ~/.gitconfig (identity in ~/.gitconfig.local)
├── aerospace/       aerospace.toml -> ~/.aerospace.toml
├── sketchybar/      -> ~/.config/sketchybar
├── borders/         -> ~/.config/borders
├── bat/             config -> ~/.config/bat/config
├── lazygit/         config.yml -> ~/Library/Application Support/lazygit/config.yml
├── atuin/           config.toml -> ~/.config/atuin/config.toml
├── mise/            config.toml -> ~/.config/mise/config.toml
├── vscode/          settings, keybindings, snippets -> VS Code; extensions.txt (see vscode/README.md)
├── claude/          statusline-command.sh -> ~/.claude/statusline-command.sh
├── fastfetch/       config.jsonc -> ~/.config/fastfetch/config.jsonc
├── .githooks/       pre-commit: gitleaks blocks commits containing secrets
├── themes/          one folder per theme: bar/border colors, Ghostty, Neovim, Starship, fzf/bat/btop, wallpaper
├── bin/             theme -> ~/.local/bin/theme (the theme switcher)
├── macos/           defaults.sh: macOS system settings (run by hand)
└── .editorconfig    -> ~/.editorconfig
```

## VS Code

Settings, keybindings and snippets live in `vscode/` and are linked into VS Code;
`install.sh` installs every extension in `vscode/extensions.txt` and makes the VS
Code terminal look like Ghostty. After installing or removing an extension, run
`vscode-ext-save` and commit. Keep VS Code's own Settings Sync off.
Details in [vscode/README.md](vscode/README.md).

## Workspaces

AeroSpace opens these apps on fixed workspaces, so `alt-<n>` always finds them:

| Workspace | Apps |
| --- | --- |
| `alt-1` | Ghostty |
| `alt-2` | Browser (Chrome, Arc, Safari, Brave, Firefox) |
| `alt-3` | Editor (Cursor, VS Code) |
| `alt-4` | Slack |

Change the numbers in the `[[on-window-detected]]` rules at the bottom of
`aerospace/aerospace.toml`. Windows already open stay put until reopened; move
them once with `alt-shift-<n>`.

## Themes

Omarchy-style: one command recolors the bar, window borders, Ghostty, Neovim,
the Starship prompt, fzf, bat, btop and the wallpaper.

```sh
theme                 # list themes, current one marked
theme set nord        # switch (or just: theme nord)
theme next            # cycle; right-clicking the Apple logo in the bar does the same
```

Included: `tokyo-night` (Omarchy's default), `catppuccin`, `gruvbox`,
`rose-pine`, `nord`, `everforest`, `kanagawa`. The active theme is the symlink
`~/.config/theme/current`. After switching, reload Ghostty with Cmd+Shift+,;
open Neovims switch when you focus them, new shell tabs get the fzf/bat colors.
lazygit and git-delta stay Catppuccin. To add a theme, copy a folder in
`themes/` and change its colors.

## SketchyBar extras

The right side shows icons only, like Omarchy's Waybar. Hover an icon for its
value (battery %, volume, CPU %, IP address); CPU turns yellow/red under load.
Click CPU for btop, Wi-Fi or battery for their settings, the logo for Raycast.


- **SERVICE** appears next to the workspaces while AeroSpace's service mode (`alt-shift-;`) is on.
- **PR count**: open PRs waiting on your review. Click to open them on GitHub. Needs `gh auth login`.
- **Slack badge**: Slack's unread count. Click to jump to workspace 4.
- **Focus timer**: click to start a 25-minute block, click again to stop.

See [`sketchybar/README.md`](sketchybar/README.md) for how the SketchyBar/AeroSpace
integration works and the full keybinding list.

## Everyday commands

| Command | What it does |
| --- | --- |
| `z <name>` | jump to a folder you've visited (zoxide) |
| `Ctrl-R` | search shell history (atuin) |
| `Ctrl-T` / `Alt-C` | fuzzy-find a file / folder (fzf) |
| `lg` | lazygit |
| `lzd` | lazydocker |
| `y` | yazi file manager |
| `gh dash` | your PRs and review requests |
| `posting` | API client in the terminal |
| `g lg` | pretty git log |
| `tldr <cmd>` | short examples for a command |
| `<cmd> \| fx` | explore JSON interactively, e.g. `curl -s api/users \| fx` |
| `ff` | system info (fastfetch); also shown in each new Ghostty tab |
| `leaks` | scan the current repo's history for secrets (gitleaks) |

## Secrets

Never commit secrets here. Commits to this repo run **gitleaks** first and are
blocked if anything looks like a key, token or password. Put tokens in
`~/.zshrc.local` or, better, in Bitwarden, and load them with the `bw` CLI.

## Updating

Configs are symlinks into this repo, so edit them in place, then:

```sh
cd ~/dotfiles
git add -A
git commit -m "update config"
git push
```

On another laptop: `cd ~/dotfiles && git pull && bash install.sh`.
On the work laptop, only pull; make changes on your personal Mac (see [PERSONAL-VS-WORK.md](PERSONAL-VS-WORK.md)).

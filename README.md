# dotfiles

Personal config for [Neovim](https://neovim.io) (via [LazyVim](https://www.lazyvim.org)), [Ghostty](https://ghostty.org), [Claude Code](https://claude.com/claude-code), [SketchyBar](https://felixkratz.github.io/SketchyBar/), and [AeroSpace](https://nikitabobko.github.io/AeroSpace/). Everything is themed **Catppuccin Mocha**.

## Layout

```
dotfiles/
├── nvim/        -> symlinked to ~/.config/nvim
├── ghostty/     -> symlinked to ~/.config/ghostty
├── claude/      -> statusline-command.sh symlinked to ~/.claude/statusline-command.sh
├── sketchybar/  -> symlinked to ~/.config/sketchybar
└── aerospace/   -> aerospace.toml symlinked to ~/.aerospace.toml
```

## Setup on a new machine

```sh
git clone https://github.com/abhishek913/dotfiles.git ~/dotfiles

mkdir -p ~/.config
rm -rf ~/.config/nvim ~/.config/ghostty ~/.config/sketchybar   # back these up first if they exist
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/ghostty ~/.config/ghostty
ln -s ~/dotfiles/sketchybar ~/.config/sketchybar
ln -s ~/dotfiles/aerospace/aerospace.toml ~/.aerospace.toml

brew install sketchybar font-sketchybar-app-font nowplaying-cli
brew install --cask nikitabobko/tap/aerospace
brew services start sketchybar
open -a AeroSpace
```

SketchyBar's workspace switcher and AeroSpace's tiling both need **Accessibility**
permission granted in System Settings > Privacy & Security > Accessibility the
first time they run.

See [`claude/README.md`](claude/README.md) for Claude Code status line setup, and
[`sketchybar/README.md`](sketchybar/README.md) for how the SketchyBar/AeroSpace
integration works, useful commands, and keybindings.

Neovim will bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) and install plugins automatically on first launch.

## Updating

Edit files directly under `~/.config/nvim` or `~/.config/ghostty` (they're symlinks into this repo), then:

```sh
cd ~/dotfiles
git add -A
git commit -m "update config"
git push
```

# dotfiles

Personal config for [Neovim](https://neovim.io) (via [LazyVim](https://www.lazyvim.org)), [Ghostty](https://ghostty.org), [Claude Code](https://claude.com/claude-code), [SketchyBar](https://felixkratz.github.io/SketchyBar/), [AeroSpace](https://nikitabobko.github.io/AeroSpace/), [Starship](https://starship.rs), and [JankyBorders](https://github.com/FelixKratz/JankyBorders). Everything is themed **Catppuccin Mocha**.

## Layout

```
dotfiles/
├── nvim/        -> symlinked to ~/.config/nvim
├── ghostty/     -> symlinked to ~/.config/ghostty
├── claude/      -> statusline-command.sh symlinked to ~/.claude/statusline-command.sh
├── sketchybar/  -> symlinked to ~/.config/sketchybar
├── aerospace/   -> aerospace.toml symlinked to ~/.aerospace.toml
├── borders/     -> symlinked to ~/.config/borders
├── git/         -> gitconfig symlinked to ~/.gitconfig (identity in ~/.gitconfig.local)
├── starship/    -> starship.toml symlinked to ~/.config/starship.toml
├── zsh/         -> aliases.zsh sourced from ~/.zshrc
└── Brewfile     -> all the brew-installed pieces above, in one file
```

## Setup on a new machine

```sh
git clone https://github.com/abhishek913/dotfiles.git ~/dotfiles

mkdir -p ~/.config
rm -rf ~/.config/nvim ~/.config/ghostty ~/.config/sketchybar ~/.config/borders   # back these up first if they exist
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/ghostty ~/.config/ghostty
ln -s ~/dotfiles/sketchybar ~/.config/sketchybar
ln -s ~/dotfiles/aerospace/aerospace.toml ~/.aerospace.toml
ln -s ~/dotfiles/borders ~/.config/borders
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig   # then create ~/.gitconfig.local, see git/README.md
echo 'source ~/dotfiles/zsh/aliases.zsh' >> ~/.zshrc

# felixkratz/formulae and nikitabobko/tap are both untrusted by default
brew trust felixkratz/formulae
brew trust nikitabobko/tap
brew bundle install --file ~/dotfiles/Brewfile

brew services start sketchybar
brew services start felixkratz/formulae/borders
open -a AeroSpace
```

SketchyBar's workspace switcher and AeroSpace's tiling both need **Accessibility**
permission granted in System Settings > Privacy & Security > Accessibility the
first time they run.

See [`git/README.md`](git/README.md) for git aliases and identity setup,
[`claude/README.md`](claude/README.md) for Claude Code status line setup, and
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

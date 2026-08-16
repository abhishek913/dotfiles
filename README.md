# dotfiles

Personal config for [Neovim](https://neovim.io) (via [LazyVim](https://www.lazyvim.org)), [Ghostty](https://ghostty.org), and [Claude Code](https://claude.com/claude-code). Neovim and Ghostty are themed **Catppuccin Mocha**.

## Layout

```
dotfiles/
├── nvim/      -> symlinked to ~/.config/nvim
├── ghostty/   -> symlinked to ~/.config/ghostty
└── claude/    -> statusline-command.sh symlinked to ~/.claude/statusline-command.sh
```

## Setup on a new machine

```sh
git clone https://github.com/abhishek913/dotfiles.git ~/dotfiles

mkdir -p ~/.config
rm -rf ~/.config/nvim ~/.config/ghostty   # back these up first if they exist
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/ghostty ~/.config/ghostty
```

See [`claude/README.md`](claude/README.md) for Claude Code status line setup.

Neovim will bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) and install plugins automatically on first launch.

## Updating

Edit files directly under `~/.config/nvim` or `~/.config/ghostty` (they're symlinks into this repo), then:

```sh
cd ~/dotfiles
git add -A
git commit -m "update config"
git push
```

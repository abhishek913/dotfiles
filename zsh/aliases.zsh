# Sourced from ~/dotfiles/zsh/zshrc

# `g` for git (not `gh`, which is the GitHub CLI). Git aliases live in git/gitconfig,
# so these combine: `g ac "msg"`, `g rbi 3`, `g pf`.
alias g="git"

# Modern replacements, only when installed
if command -v eza >/dev/null; then
  alias ls="eza --group-directories-first --icons=auto"
  alias ll="eza -l --git --group-directories-first --icons=auto"
  alias la="eza -la --git --group-directories-first --icons=auto"
  alias lt="eza --tree --level=2 --git-ignore --icons=auto"
fi
command -v bat >/dev/null && alias cat="bat --paging=never"

# TUIs
alias lg="lazygit"
alias lzd="lazydocker"
alias y="yazi"

# Neovim
alias v="nvim"

# VS Code: save the current extension list to the repo (then commit)
alias vscode-ext-save="code --list-extensions > ~/dotfiles/vscode/extensions.txt && echo saved to ~/dotfiles/vscode/extensions.txt"

# Dotfiles
alias dot="cd ~/dotfiles"
alias reload="exec zsh"

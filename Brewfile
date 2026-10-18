# Install everything:  brew bundle install --verbose --file ~/dotfiles/Brewfile
# felixkratz/formulae and nikitabobko/tap need `brew trust` first (install.sh does it)

tap "felixkratz/formulae"
tap "nikitabobko/tap"

# --- Desktop: tiling, bar, borders ---
cask "nikitabobko/tap/aerospace"
brew "sketchybar"
brew "borders"
brew "nowplaying-cli"            # SketchyBar media item
cask "font-sketchybar-app-font"
cask "raycast"                   # launcher, clipboard history, snippets

# --- Terminal + editor ---
cask "ghostty"
brew "neovim"
cask "font-jetbrains-mono-nerd-font"
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# --- CLI essentials ---
brew "git"
brew "gh"
brew "git-delta"                 # nicer git diffs
brew "jq"                        # SketchyBar media + Claude status line need it
brew "ripgrep"
brew "fd"
brew "fzf"
brew "zoxide"
brew "atuin"
brew "eza"
brew "bat"
brew "tlrc"                      # `tldr` command: short practical examples
brew "btop"
brew "yazi"

# --- Dev workflow ---
brew "mise"                      # per-project Node versions
brew "lazygit"
brew "lazydocker"
brew "uv"                        # installs `posting` (terminal API client); see install.sh
cask "bruno"                     # API client app, collections stored as files

#!/usr/bin/env bash
# Set up (or update) a Mac from ~/dotfiles. One command does everything.
#
# Brand-new Mac (nothing installed, not even git):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishek913/dotfiles/main/install.sh)"
#
# Mac that already has the repo:
#   bash ~/dotfiles/install.sh
#
# On a new Mac it installs Homebrew (which brings git), clones this repo to
# ~/dotfiles, installs every package in the Brewfile, links all configs, sets
# up themes, asks for this machine's git identity and GitHub login, and
# installs Neovim plugins. See PERSONAL-VS-WORK.md for keeping accounts apart.
#
# Safe to re-run: links that are already right are skipped, and any real file
# that would be replaced is moved aside to <name>.bak.<timestamp> first.
# Skip the Homebrew step with:  bash ~/dotfiles/install.sh --no-brew

set -euo pipefail

DOTFILES="$HOME/dotfiles"
STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_BREW=1
BREW_FAILED=0
[[ "${1:-}" == "--no-brew" ]] && RUN_BREW=0

bold() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
skip() { printf '  \033[33m•\033[0m %s\n' "$1"; }
warn() { printf '  \033[31m!\033[0m %s\n' "$1"; }

# link <path in repo> <target>
link() {
  local src="$DOTFILES/$1" dest="$2"
  if [[ ! -e "$src" ]]; then
    warn "missing in repo: $1"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    skip "$dest already linked"
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "$dest.bak.$STAMP"
    warn "moved existing $dest to $dest.bak.$STAMP"
  fi
  ln -s "$src" "$dest"
  ok "$dest -> ~/dotfiles/$1"
}

# adopt <path in repo> <target> <empty content | dir>
# First run on a Mac whose app already has settings: move them into the repo so
# link() can point back at them. With nothing to adopt, start an empty file.
adopt() {
  local repo="$DOTFILES/$1" dest="$2" empty="$3"
  [[ -e "$repo" ]] && return
  mkdir -p "$(dirname "$repo")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$repo"
    ok "moved your current $dest into ~/dotfiles/$1"
  elif [[ "$empty" == "dir" ]]; then
    mkdir -p "$repo"
  else
    printf '%s\n' "$empty" > "$repo"
  fi
}

# download <url> <target>, only if the target doesn't exist yet
download() {
  local url="$1" dest="$2"
  if [[ -f "$dest" ]]; then
    skip "$dest already downloaded"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if curl -fsSL "$url" -o "$dest"; then
    ok "downloaded $dest"
  else
    rm -f "$dest"
    warn "couldn't download $url"
  fi
}

[[ "$(uname)" == "Darwin" ]] || { warn "This setup is for macOS."; exit 1; }

load_brew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# -----------------------------------------------------------------------------
bold "0. Homebrew and the dotfiles repo"
load_brew
if command -v brew >/dev/null; then
  skip "Homebrew already installed"
else
  echo "  Installing Homebrew (it will ask for your Mac password, and may install"
  echo "  Apple's Command Line Tools, which include git)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew
  command -v brew >/dev/null || { warn "Homebrew install failed; fix that and re-run."; exit 1; }
  ok "Homebrew installed"
fi

if [[ -d "$DOTFILES/.git" ]]; then
  skip "~/dotfiles already cloned"
else
  git clone https://github.com/abhishek913/dotfiles.git "$DOTFILES"
  ok "cloned the repo to ~/dotfiles"
fi

# When this was started through curl, carry on with the repo's own copy.
if [[ "${BASH_SOURCE[0]:-}" != "$DOTFILES/install.sh" && -z "${DOTFILES_REEXEC:-}" ]]; then
  export DOTFILES_REEXEC=1
  exec bash "$DOTFILES/install.sh" ${1+"$@"}
fi

# -----------------------------------------------------------------------------
if (( RUN_BREW )); then
  bold "1. Homebrew packages"
  # these two taps are untrusted by default
  brew trust felixkratz/formulae >/dev/null 2>&1 || true
  brew trust nikitabobko/tap >/dev/null 2>&1 || true
  # Apps and fonts you installed by hand make brew refuse to install them
  # ("already an App/Font at ..."). Take each one over first: --adopt keeps the
  # copy you have, --force replaces it if it can't be adopted. Your settings and
  # data are untouched either way. After this, brew manages and updates them.
  for cask in $(grep -oE '^cask "[^"]+"' "$DOTFILES/Brewfile" | cut -d'"' -f2); do
    if ! brew list --cask "${cask##*/}" >/dev/null 2>&1; then
      brew install --cask --adopt "$cask" ||
        brew install --cask --force "$cask" ||
        warn "couldn't install $cask (brew bundle will show the error)"
    fi
  done

  # --verbose shows each package's download progress bar instead of a silent wait
  if brew bundle install --verbose --file "$DOTFILES/Brewfile"; then
    ok "Brewfile installed"
  else
    # don't stop the whole setup over one package; the rest still gets linked
    warn "some Brewfile packages failed (see the errors above); continuing with the rest"
    BREW_FAILED=1
  fi
else
  bold "1. Homebrew packages (skipped)"
fi

# -----------------------------------------------------------------------------
bold "2. Shell"
# Keep anything personal from an existing ~/.zshrc: it becomes ~/.zshrc.local,
# minus the lines the repo's zshrc now handles.
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" && ! -f "$HOME/.zshrc.local" ]]; then
  grep -v -E 'dotfiles/zsh/aliases\.zsh|starship init' "$HOME/.zshrc" > "$HOME/.zshrc.local" || true
  ok "kept your old ~/.zshrc settings in ~/.zshrc.local (review it once)"
fi
link zsh/zshrc "$HOME/.zshrc"

# -----------------------------------------------------------------------------
bold "3. App configs"
link nvim                        "$HOME/.config/nvim"
link ghostty                     "$HOME/.config/ghostty"
link sketchybar                  "$HOME/.config/sketchybar"
link borders                     "$HOME/.config/borders"
link aerospace/aerospace.toml    "$HOME/.aerospace.toml"
link starship/starship.toml      "$HOME/.config/starship.toml"
link git/gitconfig               "$HOME/.gitconfig"
link bat/config                  "$HOME/.config/bat/config"
link atuin/config.toml           "$HOME/.config/atuin/config.toml"
link mise/config.toml            "$HOME/.config/mise/config.toml"
link lazygit/config.yml          "$HOME/Library/Application Support/lazygit/config.yml"
link claude/statusline-command.sh "$HOME/.claude/statusline-command.sh"
link .editorconfig               "$HOME/.editorconfig"
link fastfetch/config.jsonc      "$HOME/.config/fastfetch/config.jsonc"

# Secret check before every commit in this repo (see .githooks/pre-commit)
if [[ "$(git -C "$DOTFILES" config core.hooksPath 2>/dev/null)" != ".githooks" ]]; then
  git -C "$DOTFILES" config core.hooksPath .githooks
  ok "gitleaks secret check turned on for ~/dotfiles commits"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  if [[ -t 0 ]]; then
    echo "  Git name and email for THIS machine (personal Mac: personal email, work laptop: work email)."
    echo "  Saved only on this machine, in ~/.gitconfig.local, never in the repo."
    read -r -p "  Name: " git_name
    read -r -p "  Email: " git_email
    printf '[user]\n\tname = %s\n\temail = %s\n' "$git_name" "$git_email" > "$HOME/.gitconfig.local"
    ok "wrote ~/.gitconfig.local"
  else
    warn "~/.gitconfig.local is missing; add your [user] name and email there (see git/README.md)"
  fi
fi

# -----------------------------------------------------------------------------
bold "3b. VS Code"
VSCODE_USER="$HOME/Library/Application Support/Code/User"
if [[ -d "/Applications/Visual Studio Code.app" ]] || command -v code >/dev/null; then
  adopt vscode/settings.json    "$VSCODE_USER/settings.json"    '{}'
  adopt vscode/keybindings.json "$VSCODE_USER/keybindings.json" '[]'
  adopt vscode/snippets         "$VSCODE_USER/snippets"         dir
  link vscode/settings.json     "$VSCODE_USER/settings.json"
  link vscode/keybindings.json  "$VSCODE_USER/keybindings.json"
  link vscode/snippets          "$VSCODE_USER/snippets"

  # Terminal look matching Ghostty, merged into settings.json (other settings untouched)
  if result=$(python3 "$DOTFILES/vscode/merge-settings.py" "$DOTFILES/vscode/settings.json" "$DOTFILES/vscode/terminal.json" 2>&1); then
    [[ "$result" == "updated" ]] && ok "VS Code terminal set to match Ghostty" || skip "VS Code terminal already matches Ghostty"
  else
    warn "couldn't update VS Code terminal settings: $result"
  fi

  # Extensions from vscode/extensions.txt (never uninstalls anything)
  if command -v code >/dev/null; then
    installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    missing=0
    while IFS= read -r ext; do
      ext="$(printf '%s' "${ext%%#*}" | tr -d '[:space:]')"
      [[ -z "$ext" ]] && continue
      if ! grep -qx "$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')" <<< "$installed"; then
        missing=1
        code --install-extension "$ext" >/dev/null 2>&1 && ok "installed extension $ext" || warn "couldn't install extension $ext"
      fi
    done < "$DOTFILES/vscode/extensions.txt"
    (( missing )) || skip "all VS Code extensions already installed"
  else
    warn "the 'code' command isn't available yet; re-run this script after VS Code is installed"
  fi
else
  skip "VS Code not installed"
fi

# -----------------------------------------------------------------------------
bold "4. Catppuccin Mocha themes"
download "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme" \
         "$HOME/.config/bat/themes/Catppuccin Mocha.tmTheme"
command -v bat >/dev/null && bat cache --build >/dev/null && ok "bat theme cache rebuilt"

download "https://github.com/catppuccin/delta/raw/main/catppuccin.gitconfig" \
         "$HOME/.config/delta/catppuccin.gitconfig"

download "https://github.com/catppuccin/btop/raw/main/themes/catppuccin_mocha.theme" \
         "$HOME/.config/btop/themes/catppuccin_mocha.theme"
BTOP_CONF="$HOME/.config/btop/btop.conf"
mkdir -p "$(dirname "$BTOP_CONF")"
if [[ -f "$BTOP_CONF" ]] && grep -q '^color_theme' "$BTOP_CONF"; then
  sed -i '' 's|^color_theme.*|color_theme = "catppuccin_mocha"|' "$BTOP_CONF"
else
  echo 'color_theme = "catppuccin_mocha"' >> "$BTOP_CONF"
fi
ok "btop theme set"

# -----------------------------------------------------------------------------
bold "5. Extra tools"
if command -v uv >/dev/null; then
  if command -v posting >/dev/null; then
    uv tool upgrade posting >/dev/null 2>&1 && skip "posting already installed (updated if needed)"
  else
    uv tool install posting >/dev/null 2>&1 && ok "installed posting (terminal API client)"
  fi
fi
if command -v gh >/dev/null; then
  if ! gh auth status >/dev/null 2>&1 && [[ -t 0 ]]; then
    echo "  Logging in to GitHub (for gh dash and the PR count in SketchyBar)."
    echo "  Use the account for THIS machine: personal on your Mac, work on the work laptop."
    gh auth login --hostname github.com --git-protocol https --web || true
  fi
  if gh auth status >/dev/null 2>&1; then
    if gh extension list 2>/dev/null | grep -q gh-dash; then
      gh extension upgrade gh-dash >/dev/null 2>&1 || true
      skip "gh-dash already installed (updated if needed)"
    else
      gh extension install dlvhdr/gh-dash >/dev/null 2>&1 && ok "installed gh-dash (run: gh dash)"
    fi
  else
    warn "not logged in to GitHub; run 'gh auth login' then re-run this script to add gh-dash"
  fi
fi

if command -v nvim >/dev/null; then
  echo "  Installing Neovim plugins (first time takes a minute)..."
  if nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
    ok "Neovim plugins installed"
  else
    warn "Neovim plugin install had problems; open nvim and run :Lazy to see why"
  fi
fi

# -----------------------------------------------------------------------------
bold "6. Start the desktop pieces"
if command -v sketchybar >/dev/null; then
  brew services restart sketchybar >/dev/null && ok "SketchyBar (re)started"
fi
if command -v borders >/dev/null; then
  brew services restart felixkratz/formulae/borders >/dev/null && ok "borders (re)started"
fi
if [[ -d "/Applications/AeroSpace.app" ]]; then
  if pgrep -x AeroSpace >/dev/null; then
    aerospace reload-config && ok "AeroSpace config reloaded"
  else
    open -a AeroSpace && ok "AeroSpace started"
  fi
fi

# -----------------------------------------------------------------------------
bold "Done"
if (( BREW_FAILED )); then
  warn "Some Homebrew packages didn't install. Fix the error shown above, then re-run: bash ~/dotfiles/install.sh"
fi
cat << 'EOF'
  Open a new terminal tab (or run: exec zsh) to load the new shell.

  One-time steps on a new Mac (these need you, not a script):
    - Grant Accessibility to AeroSpace (System Settings > Privacy & Security)
    - Optional: atuin register      # history sync; keep work and personal on separate atuin accounts
    - mise use -g node@24           # if you want mise to manage Node
    - bash ~/dotfiles/macos/defaults.sh   # optional macOS settings
EOF

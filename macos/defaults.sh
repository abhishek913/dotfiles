#!/usr/bin/env bash
# macOS system settings, so a new Mac behaves like this one.
# Run once:  bash ~/dotfiles/macos/defaults.sh
# Safe to re-run. Some settings need a logout/restart to take effect.
# Comment out anything you don't want before running.

set -euo pipefail

echo "Applying macOS defaults..."

# --- Keyboard ---
# Fast key repeat (good for holding j/k in Neovim). Lower = faster.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Hold a key to repeat it, instead of showing the accent picker
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# No autocorrect / smart quotes / smart dashes (they break code pasted into chats)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# --- Menu bar ---
# Hide the macOS menu bar; SketchyBar replaces it (it still appears when you move the mouse to the top)
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 44
# Don't rearrange Spaces by recent use (AeroSpace recommends this)
defaults write com.apple.dock mru-spaces -bool false
# Group windows by app in Mission Control (AeroSpace recommends this; its windows look tiny otherwise)
defaults write com.apple.dock expose-group-apps -bool true

# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true          # hidden files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true        # file extensions
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search the current folder
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Screenshots ---
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Trackpad ---
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true  # tap to click

# --- Apply ---
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "Done. Log out and back in for keyboard and menu bar changes to fully apply."

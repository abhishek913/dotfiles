#!/usr/bin/env bash
# One-time setup for a second (work) GitHub account on this Mac.
#
# After running this:
#   - any repo under ~/<work folder>/ commits with your work name/email
#   - repos cloned as git@github-work:org/repo.git push with your work SSH key
#   - everything else keeps using your personal setup, untouched
#
# Safe to re-run: it skips anything that is already set up.
#
# Usage:  bash ~/dotfiles/git/setup-work-account.sh

set -euo pipefail

bold() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
skip() { printf '  \033[33m•\033[0m %s\n' "$1"; }
warn() { printf '  \033[31m!\033[0m %s\n' "$1"; }

SSH_HOST="github-work"
SSH_KEY="$HOME/.ssh/id_work"
LOCAL_CFG="$HOME/.gitconfig.local"
WORK_CFG="$HOME/.gitconfig.work"
SSH_CFG="$HOME/.ssh/config"

# ---------------------------------------------------------------------------
bold "Work GitHub account setup"

default_name="$(git config --global user.name 2>/dev/null || true)"
read -r -p "  Work name for commits [${default_name}]: " work_name
work_name="${work_name:-$default_name}"

work_email=""
while [[ -z "$work_email" ]]; do
  read -r -p "  Work email: " work_email
done

read -r -p "  Folder for work repos, inside your home folder [work]: " work_folder
work_folder="${work_folder:-work}"
work_folder="${work_folder%/}"
WORK_DIR="$HOME/$work_folder"

# ---------------------------------------------------------------------------
bold "1. Work folder"
if [[ -d "$WORK_DIR" ]]; then
  skip "$WORK_DIR already exists"
else
  mkdir -p "$WORK_DIR"
  ok "Created $WORK_DIR"
fi

# ---------------------------------------------------------------------------
bold "2. Work identity"
cat > "$WORK_CFG" << EOF
[user]
	name = $work_name
	email = $work_email
EOF
ok "Wrote $WORK_CFG"

if [[ ! -f "$LOCAL_CFG" ]]; then
  touch "$LOCAL_CFG"
  warn "$LOCAL_CFG didn't exist; created it. Add your personal [user] name/email there."
fi

if git config -f "$LOCAL_CFG" --get "includeIf.gitdir:~/$work_folder/.path" >/dev/null 2>&1; then
  skip "includeIf rule for ~/$work_folder/ already in $LOCAL_CFG"
else
  git config -f "$LOCAL_CFG" "includeIf.gitdir:~/$work_folder/.path" "$WORK_CFG"
  ok "Repos under ~/$work_folder/ will use $work_email"
fi

if ! git config --global --get include.path 2>/dev/null | grep -q gitconfig.local; then
  warn "~/.gitconfig doesn't include ~/.gitconfig.local. Is it linked to ~/dotfiles/git/gitconfig?"
fi

# ---------------------------------------------------------------------------
bold "3. SSH key"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [[ -f "$SSH_KEY" ]]; then
  skip "$SSH_KEY already exists, reusing it"
else
  echo "  Creating a new key. Set a passphrase when asked (it gets saved in Keychain)."
  ssh-keygen -t ed25519 -C "$work_email" -f "$SSH_KEY"
  ok "Created $SSH_KEY"
fi

# Save the passphrase to the macOS Keychain so you only type it once.
ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY" 2>/dev/null || true

# ---------------------------------------------------------------------------
bold "4. SSH config"
touch "$SSH_CFG" && chmod 600 "$SSH_CFG"
if grep -qE "^Host[[:space:]]+$SSH_HOST\$" "$SSH_CFG"; then
  skip "Host $SSH_HOST already in $SSH_CFG"
else
  cat >> "$SSH_CFG" << EOF

Host $SSH_HOST
  HostName github.com
  User git
  IdentityFile $SSH_KEY
  IdentitiesOnly yes
  AddKeysToAgent yes
  IgnoreUnknown UseKeychain
  UseKeychain yes
EOF
  ok "Added Host $SSH_HOST"
fi

# ---------------------------------------------------------------------------
bold "5. Add the key to your WORK GitHub account"
test_ssh() {
  ssh -T -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "git@$SSH_HOST" 2>&1 || true
}

result="$(test_ssh)"
if grep -q "successfully authenticated" <<< "$result"; then
  skip "Key already works on GitHub"
else
  if pbcopy < "$SSH_KEY.pub" 2>/dev/null; then
    ok "Public key copied to your clipboard"
  else
    echo "  Copy this public key:"; echo; cat "$SSH_KEY.pub"
  fi
  echo
  echo "  Opening GitHub's 'Add new SSH key' page."
  echo "  Make sure the browser is signed in to your WORK account, not personal."
  echo "  Title: anything (e.g. 'MacBook'), Key type: Authentication Key, then paste and save."
  echo "  If your company uses SSO: click 'Configure SSO' next to the key and authorize your org."
  open "https://github.com/settings/ssh/new" 2>/dev/null || echo "  Go to: https://github.com/settings/ssh/new"
  echo
  read -r -p "  Press Enter once you've saved the key on GitHub... " _
  result="$(test_ssh)"
fi

# ---------------------------------------------------------------------------
bold "6. Testing the connection"
if grep -q "successfully authenticated" <<< "$result"; then
  user="$(sed -nE 's/.*Hi ([^!]+)!.*/\1/p' <<< "$result")"
  ok "Connected to GitHub as: $user"
  echo "     (If that's your personal username, the key was added to the wrong account.)"
else
  warn "Couldn't authenticate yet. GitHub said:"
  echo "     $result"
  echo "     Fix it, then test again with:  ssh -T git@$SSH_HOST"
fi

# ---------------------------------------------------------------------------
bold "Done"
cat << EOF
  Clone work repos like this (copy the SSH URL from GitHub, swap the host):
      git clone git@$SSH_HOST:company/repo.git ~/$work_folder/repo

  Move an existing work repo over:
      mv path/to/repo ~/$work_folder/repo
      cd ~/$work_folder/repo
      git remote set-url origin git@$SSH_HOST:company/repo.git

  Check a repo:
      git config user.email     # work email inside ~/$work_folder/
      git remote -v             # should show git@$SSH_HOST:...
EOF

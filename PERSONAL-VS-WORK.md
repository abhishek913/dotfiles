# Personal vs work

**Rule:** this repo holds only config that's the same everywhere. Anything tied to
an account stays on each machine, outside the repo:

| What | Where it lives (never committed) |
| --- | --- |
| Git name and email | `~/.gitconfig.local` |
| Work paths, env vars, tokens | `~/.zshrc.local` |
| SSH keys | `~/.ssh/` |
| GitHub CLI login | `gh auth login` |

So the same repo works on both laptops without mixing anything.

## Personal Mac

```sh
bash ~/dotfiles/install.sh
```

When asked, enter your **personal** name/email and log in to GitHub with your
**personal** account. That's it. Nothing work-related goes on this Mac.

## Work laptop

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishek913/dotfiles/main/install.sh)"
```

1. When asked, enter your **work** name/email and log in to GitHub with your **work** account.
   SketchyBar's PR count then shows your work reviews.
2. Put anything work-specific in `~/.zshrc.local`, never in the repo.
3. **Only pull here, don't push.** Make config changes on your personal Mac, push
   them, then on the work laptop run:

   ```sh
   cd ~/dotfiles && git pull && bash install.sh
   ```

   Pulling over HTTPS needs no login while the repo is public, so your personal
   GitHub account never touches the work laptop.
4. Shell history (atuin): don't sync it between the two laptops. Either skip
   `atuin register` on the work laptop, or use a separate atuin account there.

## Quick check

Run these on either laptop; they should show that machine's account:

```sh
git config user.email   # inside any repo
gh auth status
```

## Later, only if you need it: both accounts on one Mac

You don't need this now. If you ever have to do work from your personal Mac:

```sh
bash ~/dotfiles/git/setup-work-account.sh
```

Repos inside `~/work/` then commit with your work email and push with a separate
work SSH key; everything else stays personal. Details in [git/README.md](git/README.md).

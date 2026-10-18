# Git

`gitconfig` is linked to `~/.gitconfig` by `install.sh`. Your name and email go
in `~/.gitconfig.local`, which `install.sh` asks for and which is never committed,
so each machine keeps its own identity. See [PERSONAL-VS-WORK.md](../PERSONAL-VS-WORK.md).

## Aliases

| Alias           | Runs                                  |
|-----------------|---------------------------------------|
| `git a`         | `git add .`                           |
| `git cm "msg"`  | `git commit -m "msg"`                 |
| `git ac "msg"`  | `git add .` then `git commit -m "msg"`|
| `git rbi 3`     | `git rebase -i HEAD~3`                |
| `git pu`        | `git push -u origin <current branch>` |
| `git pf`        | `git push --force-with-lease`         |
| `git st`        | short status                          |
| `git lg`        | compact graph log                     |
| `git undo`      | undo the last commit, keep the changes |
| `git fix <sha>` | make a fixup commit for `<sha>` (folded in by `rbi`) |

`g` is aliased to `git` in zsh, so `g ac "msg"` works too.

## Defaults worth knowing

- `git pull` rebases instead of merging, stashing uncommitted changes around it.
- `git push` on a new branch sets up the remote automatically.
- Diffs go through delta (Catppuccin) when it's installed.
- Conflicts show the original text too (`zdiff3`), and resolutions are remembered (`rerere`).

## Optional: work account on the same Mac

Only needed if you ever do work from your personal Mac. Run once:

```sh
bash ~/dotfiles/git/setup-work-account.sh
```

It asks for your work name/email, then sets up `~/work/` so repos there commit
with your work identity, creates an SSH key, opens GitHub so you can add it, and
adds a `github-work` SSH host. Clone work repos as
`git@github-work:company/repo.git` into `~/work/`. Safe to re-run.

Nothing it creates is stored in this repo (`~/.gitconfig.work`, `~/.ssh/`).

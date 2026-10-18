# Git

`gitconfig` is symlinked to `~/.gitconfig`. Identity (name/email) goes in
`~/.gitconfig.local`, which is pulled in via `[include]` and is not committed.

## Setup on a new machine

```sh
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig

cat > ~/.gitconfig.local << 'LOCAL'
[user]
	name = Your Name
	email = you@example.com
LOCAL
```

## Aliases

| Alias           | Runs                                  |
|-----------------|---------------------------------------|
| `git a`         | `git add .`                           |
| `git cm "msg"`  | `git commit -m "msg"`                 |
| `git ac "msg"`  | `git add .` then `git commit -m "msg"`|
| `git rbi 3`     | `git rebase -i HEAD~3`                |
| `git pu`        | `git push -u origin <current branch>` |
| `git pf`        | `git push --force-with-lease`         |

## Second (work) GitHub account

Run once per machine:

```sh
bash ~/dotfiles/git/setup-work-account.sh
```

It asks for your work name/email, then sets up `~/work/` so repos there commit
with your work identity, creates an SSH key, opens GitHub so you can add it, and
adds a `github-work` SSH host. Clone work repos as
`git@github-work:company/repo.git` into `~/work/`. Safe to re-run.

Nothing it creates is stored in this repo (`~/.gitconfig.work`, `~/.ssh/`).

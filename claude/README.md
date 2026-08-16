# Claude Code status line

`statusline-command.sh` prints a single status line for [Claude Code](https://claude.com/claude-code):
model name · current directory · git branch (`*` if dirty) · context window usage ·
5-hour rate-limit usage (if reported) · non-default output style.

## Setup on a new machine

```sh
ln -sf ~/dotfiles/claude/statusline-command.sh ~/.claude/statusline-command.sh
```

Then add this to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash \"$HOME/.claude/statusline-command.sh\""
  }
}
```

Requires `jq`.

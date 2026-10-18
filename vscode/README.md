# VS Code

Settings, keybindings, snippets and the extension list, shared across laptops
without signing in to Settings Sync.

| File | Linked to |
| --- | --- |
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` |
| `snippets/` | `~/Library/Application Support/Code/User/snippets` |
| `extensions.txt` | installed by `install.sh` with `code --install-extension` |
| `terminal.json` | merged into `settings.json` so the VS Code terminal matches Ghostty |

The first time `install.sh` runs on a Mac that already has VS Code settings and
this folder doesn't have them yet, it moves them in here and links them back.
After that, changing a setting in VS Code edits the file in this repo.

## Day to day

- **Changed a setting or keybinding:** it's already in the repo. Just commit.
- **Installed or removed an extension:** run `vscode-ext-save` to refresh
  `extensions.txt`, then commit.
- **Other laptop:** `git pull && bash install.sh` installs any missing extensions.
  It never uninstalls extensions, so work-only ones on the work laptop are safe.

To change the terminal look, edit `terminal.json` (or Ghostty and this together),
then re-run `install.sh`.

Keep VS Code's own Settings Sync **off**, so it doesn't fight with these files.

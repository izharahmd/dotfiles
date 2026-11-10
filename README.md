# dotfiles

Personal dotfiles, applied to `$HOME` as symlinks.

```sh
./install.sh --dry-run   # show what would change
./install.sh --skip .gitconfig --skip .vimrc   # leave these files alone
./install.sh             # apply
```

- Safe to re-run: links that already point at this repo are skipped.
- Existing files at the destination are moved to `<name>.bak.<timestamp>`, never deleted.
- To manage another dotfile, add its name to `FILES` in `install.sh`.
- To always skip files on this machine, list them in `.install-skip` (one per line, `#` comments allowed). It is gitignored, so it stays local. `--skip` adds to it.
- `./install-completions.sh [--dry-run]` installs the `zsh-completions` oh-my-zsh plugin that `.zshrc` enables, and generates `~/.oh-my-zsh/completions/_<tool>` for each tool in the `TOOLS` array (needs oh-my-zsh; re-run to update). A tool entry is `name` (runs `name completion zsh`) or `name=custom command`. Tools that aren't installed are skipped. Machine-local tools go in a gitignored `.install-completion-tools` file (one entry per line, same format, `#` comments allowed); they are added to the `TOOLS` array.

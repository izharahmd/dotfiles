# dotfiles

Personal dotfiles, applied to `$HOME` as symlinks.

```sh
./install.sh --dry-run   # show what would change
./install.sh             # apply
```

- Safe to re-run: links that already point at this repo are skipped.
- Existing files at the destination are moved to `<name>.bak.<timestamp>`, never deleted.
- To manage another dotfile, add its name to `FILES` in `install.sh`.

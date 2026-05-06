# Dotfiles TODO Changes

## High Priority

### Hardcoded paths in `bash/functions.sh`
The `todo()` function and potentially others use `/home/bnm/` literally instead of `$HOME`.
This breaks on macOS or for any other user.
- Change `/home/bnm/TODO.txt` → `"$HOME/TODO.txt"` (and anywhere else `/home/bnm/` appears)

### Hardcoded gcloud paths in `zsh/zshrc`
The Google Cloud SDK block hardcodes `/home/bnm/` paths and sources them unconditionally.
- Replace with `$HOME`-relative paths
- Guard each `source` with a file existence check (e.g. `[ -f "$HOME/..." ] && source ...`)

---

## Medium Priority

### Duplicate / inconsistent FZF config
`FZF_DEFAULT_OPTS` is defined in both `zsh/zshenv` and `bash/env.sh` with slight differences
(bash is missing `-m` for multiselect). These will drift over time.
- Consolidate into a single shared env file, or keep them in sync explicitly

### `psqlrc` editor set to `code`
Everything else defers to `nvim` or `$EDITOR`, but `psqlrc` hardcodes VS Code.
- Change `\setenv EDITOR code` → `\setenv EDITOR nvim` (or `$EDITOR` if psql supports it)

### Biome binary resolution in `nvim/my_modules/biome_linter.lua`
There is an existing TODO in the file: prefer a project-local `./node_modules/.bin/biome`
before falling back to a global install.
- Check for `./node_modules/.bin/biome` first to avoid version mismatches in projects

---

## Low Priority / Cleanup

### Remove `nvim/coc-settings.json`
This is legacy CoC.nvim config that is no longer used since moving to native LSP.
- Safe to delete

### Profile zsh startup time
`zprof` is commented out in `zsh/zshrc`. With 40+ nvim plugins and lazy-loaded tools,
it is worth a one-time profiling pass to catch any unexpectedly slow startup steps.
- Temporarily enable `zprof` at top and bottom of zshrc, run `zsh -i -c exit`, review output

# TODO

## Ubuntu

- [ ] Upgrade Ubuntu 20.04 → 22.04+
- [ ] Migrate nvim to bob-managed after upgrade

## Neovim — LSP & Tooling

- [ ] Verify rustaceanvim works (open a Rust file, check LSP attaches and
      rust-analyzer downloads)
- [ ] Fix tmux navigate when in terminal window
- [ ] Fix retrieval of LSP docs/hover
- [ ] Setup trouble & LSP navigation
- [ ] clang_format: verify conform handles C/C++/proto correctly

## Neovim — Markdown

- [ ] Evaluate markdown linters: proselint, vale, harper, markdownlint
- [ ] Enable toggling of active linter for markdown buffers

## Neovim — Web (low priority)

- [ ] CSS: stylelint (https://github.com/stylelint/stylelint)
- [ ] HTML: html-tidy (https://www.html-tidy.org/)
- [ ] HTML: htmlhint (https://htmlhint.com/)

## Neovim — Plugins to check out

- [ ] leap.nvim
- [ ] flash.nvim
- [ ] harpoon
- [ ] eyeliner

## Tools

- [ ] Clean up `tools/`: keep `.py` suffixes and expose shell commands through
      `~/.local/bin` symlinks
- [ ] Update `setup.sh` to sync new tool scripts and symlinks
- [ ] Add shell commands: `menu`, `nightmode`, `project_pick`, and possibly
      `chatgpt`
- [ ] Build `project_pick.py`: select curated projects with fzf, switch to an
      existing tmux session, or create a session/window/pane as appropriate
- [ ] Revisit whether `project_pick.py` needs Questionary/Textual after trying
      fzf

## Tmux

- [ ] Set up `tmux-resurrect` without `tmux-continuum`; test manual save/restore
- [ ] Add a `systemd --user` logout/shutdown save hook
- [ ] Decide whether tmux restore should remain manual or become automatic
- [ ] Unify tmux and Alacritty copy workflows: use Alacritty vi mode as the
      fallback, align selection/copy keys (`v`/`y`), and target the system
      clipboard
- [ ] Verify the copy workflow in normal tmux panes and popups

## Known Warnings / Bugs

- [ ] rustaceanvim: `client.request is deprecated` warning on Rust file open
      monitor rustaceanvim updates, will resolve upstream

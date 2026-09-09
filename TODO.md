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

## Known Warnings / Bugs

- [ ] rustaceanvim: `client.request is deprecated` warning on Rust file open
      monitor rustaceanvim updates, will resolve upstream

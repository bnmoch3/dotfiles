# Mac Setup Reference

## Fresh Machine: Do This First

### 1. SSH key for GitHub

```bash
ssh-keygen -t ed25519 -C "email" -f ~/.ssh/id_ed25519_github
cat ~/.ssh/id_ed25519_github.pub
# add the public key to GitHub → Settings → SSH keys
```

### 2. Clone dotfiles

```bash
git clone git@github.com:bnmoch3/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash setup.sh
```

setup.sh symlinks all config files. If destinations already exist:

```bash
bash setup.sh --overwrite
```

---

## Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"  # add to shell for current session
```

Homebrew is the primary package manager for everything on Mac. The shellenv line
is handled by zshrc/zshenv after dotfiles are symlinked.

---

## System Preferences

```bash
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write com.apple.finder AppleShowAllFiles YES
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```

Key repeat can also be set in System Settings → Keyboard → set to fastest.

---

## CLI Tools

### Install all at once

```bash
brew install \
    bash \
    coreutils \
    git \
    git-lfs \
    tmux \
    fzf \
    ripgrep \
    bat \
    eza \
    atuin \
    starship \
    shellcheck \
    shfmt \
    procs \
    tldr \
    duf \
    gping \
    entr \
    luacheck \
    lazygit \
    git-delta \
    jq \
    zoxide \
    btop \
    yazi \
    fd \
    biome \
    sqlite \
    stylua \
    taplo \
    yamlfmt \
    libpq \
    wget \
    go \
    deno \
    trash

brew link --force libpq  # makes psql CLI available
```

### fzf shell integration

```bash
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
# generates ~/.fzf.zsh, sourced from zshrc
```

### git-lfs

```bash
git lfs install
```

### Tool reference

| Tool         | Purpose                                |
| ------------ | -------------------------------------- |
| bash         | newer bash than macOS default          |
| coreutils    | GNU coreutils (gls, gdate, etc.)       |
| git, git-lfs | version control                        |
| tmux         | terminal multiplexer                   |
| fzf          | fuzzy finder, used in shell and nvim   |
| ripgrep (rg) | fast grep, used as fzf default command |
| bat          | cat replacement, used as pager         |
| eza          | ls replacement (maintained exa fork)   |
| atuin        | shell history with search              |
| starship     | shell prompt                           |
| shellcheck   | shell script linter                    |
| shfmt        | shell formatter                        |
| procs        | ps replacement                         |
| tldr         | cheatsheets                            |
| duf          | df replacement                         |
| gping        | ping with graph                        |
| entr         | run command on file change             |
| luacheck     | lua linter (for nvim config)           |
| lazygit      | terminal UI for git                    |
| git-delta    | better git diff pager                  |
| jq           | JSON processor                         |
| zoxide       | smarter cd                             |
| btop         | system monitor                         |
| yazi         | terminal file manager                  |
| fd           | fast file finder                       |
| biome        | JS/TS formatter and linter             |
| sqlite       | SQLite CLI                             |
| stylua       | Lua formatter                          |
| taplo        | TOML formatter                         |
| yamlfmt      | YAML formatter                         |
| libpq        | PostgreSQL client library (psql CLI)   |
| wget         | HTTP downloader                        |
| go           | Go toolchain (brew manages on Mac)     |
| deno         | Deno runtime (used for deno_fmt)       |
| trash        | safe delete to Trash (instead of rm)   |

---

## Rust + Cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

cargo is used to install bob (nvim version manager). `~/.cargo/env` is sourced
in zshenv.

---

## Neovim (via bob)

bob manages neovim versions, similar to how mise manages node.

```bash
cargo install bob-nvim
bob install 0.12.2
bob use 0.12.2
```

bob installs nvim to `~/.local/share/bob/nvim-bin`, which is on PATH via zshenv:

```bash
[[ -d "$HOME/.local/share/bob/nvim-bin" ]] && export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
```

Useful bob commands:

```bash
bob list                  # list installed versions
bob install <version>     # install a version
bob use <version>         # switch active version
```

### Neovim config

- Location: `~/dotfiles/nvim/` (symlinked to `~/.config/nvim/`)
- Plugin manager: **lazy.nvim** (bootstrapped automatically on first nvim
  launch)
- LSP: **vim.lsp.config + vim.lsp.enable** (native nvim 0.12+ API, not
  lspconfig)
- Treesitter: **main branch**, highlighting via FileType autocmd
  (`pcall(vim.treesitter.start)`)
- Rust: **rustaceanvim** (not rust-tools.nvim which is unmaintained)

On first launch, lazy.nvim installs all plugins automatically. Then inside nvim:

```
:MasonInstall lua-language-server pyright gopls typescript-language-server
              rust-analyzer bash-language-server json-lsp yaml-language-server
              html-lsp css-lsp biome taplo

:TSInstall all
```

### Mason LSP servers

- lua-language-server
- pyright
- gopls
- typescript-language-server
- rust-analyzer (managed by rustaceanvim, not called via vim.lsp.enable)
- bash-language-server
- json-lsp
- yaml-language-server
- html-lsp
- css-lsp
- biome
- taplo

### Active LSP servers (vim.lsp.enable)

pyright, gopls, clangd, ts_ls, buf_ls, lua_ls, vimls, taplo, yamlls

### Formatters (conform.nvim, format on save)

| Formatter           | Filetype                       |
| ------------------- | ------------------------------ |
| stylua              | lua                            |
| taplo               | toml                           |
| yamlfmt             | yaml                           |
| gofumpt + goimports | go                             |
| ruff                | python                         |
| sqlfmt              | sql                            |
| biome               | js, ts, html, css, json, jsonc |
| shfmt               | sh                             |
| deno_fmt            | markdown                       |
| buf                 | proto                          |

Note: sqlfmt is excluded for files matching `migrations/` path pattern.

### Linters (nvim-lint)

| Linter       | Filetype   |
| ------------ | ---------- |
| ruff         | python     |
| luacheck     | lua        |
| checkmake    | make       |
| shellcheck   | sh         |
| hadolint     | dockerfile |
| golangcilint | go         |
| biome        | js, ts     |

---

## mise (Node, DuckDB, runtime manager)

mise replaces nvm for node version management and also manages duckdb and other
runtimes.

```bash
curl https://mise.run | sh
eval "$($HOME/.local/bin/mise activate zsh)"  # already in dotfiles zshrc

mise install node@lts
mise use -g node@lts

npm install -g yarn neovim
```

Useful mise commands:

```bash
mise install node@lts          # install a runtime
mise use -g node@lts           # set global default
mise install duckdb@latest     # install duckdb
mise list                      # list installed runtimes
```

nvm is no longer used. Any nvm references in bash/env.sh are Linux legacy and
only affect bash on ThinkPad.

---

## uv (Python)

uv manages Python tooling. Replaces pyenv + pip for most purposes.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Python CLI tools installed via uv tool:

```bash
uv tool install ruff
uv tool install shandy-sqlfmt
```

`PIP_REQUIRE_VIRTUALENV=true` is set in zshenv outside the interactive block so
it applies to all contexts including scripts. Always use `uv` instead of bare
pip.

---

## Go Tools

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
```

Go is installed via brew on Mac. GOPATH/bin is on PATH via zshenv:

```bash
[[ -d "$(go env GOPATH 2>/dev/null)/bin" ]] && export PATH="$PATH:$(go env GOPATH)/bin"
```

---

## PostgreSQL

Postgres.app is used on Mac (not brew postgres). Download and install manually
from https://postgresapp.com.

## Alacritty

```bash
brew install --cask alacritty
brew install --cask font-jetbrains-mono-nerd-font
```

Config: `~/dotfiles/alacritty.toml` → `~/.config/alacritty/alacritty.toml`

Font: JetBrainsMono Nerd Font, size 13.

---

## Keyboard & Window Management

### Karabiner-Elements

```bash
brew install --cask karabiner-elements
```

Config: `~/dotfiles/karabiner.json` → `~/.config/karabiner/karabiner.json`

Rules:

- Caps Lock ↔ Escape swap (for vim)
- Ctrl+C/V/X/Z/S/A → Cmd equivalent, **excluding** org.alacritty (where Ctrl is
  used directly in the terminal)

Grant Accessibility permissions in System Settings when prompted.

### Rectangle (window snapping)

```bash
brew install --cask rectangle
```

Shortcuts: Cmd+Left (left half), Cmd+Right (right half), Cmd+Up (maximize).
Grant Accessibility permissions.

### AltTab

```bash
brew install --cask alt-tab
```

Config: Cmd+Tab, show windows from Visible Spaces only.

---

## git/gitconfig Highlights

- delta as pager for diff/log/show
- nvim as editor
- rebase = true on pull
- rerere enabled
- SSH URL rewrite for GitHub (`insteadOf = https://github.com/`)

---

## Atuin Sync (do when needed)

Syncs shell history between Mac and ThinkPad.

```bash
# if registering for the first time:
atuin register -u <username> -e <email> -p <password>

# if already registered on another machine:
atuin login -u <username>
atuin sync
```

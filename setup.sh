#!/usr/bin/env bash
# setup.sh - symlink dotfiles into place

set -e

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

_info()  { echo "info  $*"; }
_warn()  { echo "warn  $*"; }
_error() { echo "error $*" >&2; exit 1; }

# create a symlink from a dotfiles file/dir to its destination
# usage: _link <source-relative-to-dotfiles-root> <destination-full-path>
_link() {
    local src
    src="$(realpath "$DOTFILES_DIR/$1")"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    if [[ ! -f "$src" && ! -d "$src" ]]; then
        _error "source does not exist: $src"
    fi

    if [[ ! -d "$dest_dir" ]]; then
        _info "mkdir $dest_dir"
        [[ $DRY_RUN == 1 ]] || mkdir -p "$dest_dir"
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ $OVERWRITE == 1 ]]; then
            _info "overwrite $src -> $dest"
            [[ $DRY_RUN == 1 ]] || ln -sf "$src" "$dest"
        else
            _warn "already exists, skipping: $dest (use -o to overwrite)"
        fi
    else
        _info "link $src -> $dest"
        [[ $DRY_RUN == 1 ]] || ln -s "$src" "$dest"
    fi
}

_setup_local_bin() {
    _info "bin path: $BIN_PATH"
    if [[ ":$PATH:" == *":$BIN_PATH:"* ]]; then
        _info "PATH already contains $BIN_PATH"
    else
        _warn "PATH does not contain $BIN_PATH"
    fi
    if [[ ! -d "$BIN_PATH" ]]; then
        _info "mkdir $BIN_PATH"
        [[ $DRY_RUN == 1 ]] || mkdir -p "$BIN_PATH"
    fi
}

# ---------------------------------------------------------------------------
# configs
# ---------------------------------------------------------------------------

_setup_configs() {
    # --- bash ---
    _link "bash/bashrc"       "$HOME/.bashrc"

    # --- zsh ---
    _link "zsh/zshrc"         "$HOME/.zshrc"
    _link "zsh/zshenv"        "$HOME/.zshenv"
    _link "zsh/functions.zsh" "$HOME/.config/zsh/functions.zsh"
    _link "zsh/auto-venv.zsh" "$HOME/.config/zsh/auto-venv.zsh"
    _link "zsh/external/completion.zsh" "$HOME/.config/zsh/external/completion.zsh"

    # --- git ---
    _link "git/gitconfig"     "$HOME/.gitconfig"
    _link "git/gitignore"     "$HOME/.gitignore"

    # --- tmux ---
    _link "tmux.conf"         "$HOME/.tmux.conf"

    # --- readline ---
    _link "inputrc"           "$HOME/.inputrc"

    # --- db clients ---
    _link "psqlrc"            "$HOME/.psqlrc"
    _link "sqliterc"          "$HOME/.sqliterc"

    # --- alacritty (config path differs by os) ---
    if [[ "$OSTYPE" == "darwin"* ]]; then
        _link "alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    else
        _link "alacritty.toml" "$HOME/.alacritty.toml"
    fi

    # --- atuin ---
    _link "atuin/config.toml" "$HOME/.config/atuin/config.toml"

    # --- starship ---
    _link "starship.toml"     "$HOME/.config/starship.toml"

    # --- nvim ---
    _link "nvim/init.lua"          "$HOME/.config/nvim/init.lua"
    _link "nvim/vimrc"             "$HOME/.vimrc"
    _link "nvim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"
    _link "nvim/my_modules"        "$HOME/.config/nvim/lua/my_modules"
    _link "nvim/ftplugin"          "$HOME/.config/nvim/ftplugin"
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

setup() {
    _setup_local_bin
    _setup_configs
}

usage() {
    cat <<-EOF
usage: $0 [-h] [-n] [-o] [-b <path>]

symlink dotfiles into place.

options:
  -h, --help            show this help and exit
  -n, --dry-run         print what would be done without doing it
  -o, --overwrite       overwrite existing symlinks/files
  -b, --bin-path <path> path for local binaries (default: ~/LOCAL/bin)
EOF
}

# ---------------------------------------------------------------------------
# args
# ---------------------------------------------------------------------------

DRY_RUN=0
OVERWRITE=0
BIN_PATH="$HOME/LOCAL/bin"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ -n "$1" ]]; do
    case "$1" in
        -n | --dry-run)   DRY_RUN=1 ;;
        -o | --overwrite) OVERWRITE=1 ;;
        -h | --help)      usage; exit 0 ;;
        -b | --bin-path)
            shift
            BIN_PATH="$1"
            [[ -d "$BIN_PATH" || $DRY_RUN == 1 ]] || _error "invalid bin path: $BIN_PATH"
            ;;
        *) usage >&2; exit 1 ;;
    esac
    shift
done

setup

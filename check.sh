#!/usr/bin/env bash
# check.sh - verify that required and optional tools are installed
# works on both linux (ubuntu) and macos
# requires bash 4+ (brew install bash on macos)

# ---------------------------------------------------------------------------
# colors
# ---------------------------------------------------------------------------
_red()    { printf '\033[0;31m%s\033[0m' "$*"; }
_green()  { printf '\033[0;32m%s\033[0m' "$*"; }
_yellow() { printf '\033[0;33m%s\033[0m' "$*"; }
_bold()   { printf '\033[1m%s\033[0m' "$*"; }

# ---------------------------------------------------------------------------
# version checking
# ---------------------------------------------------------------------------
_get_version() {
    local cmd=$1
    case "$cmd" in
        nvim)       "$cmd" --version 2>&1 | head -1 ;;
        go)         "$cmd" version    2>&1 | head -1 ;;
        node)       "$cmd" --version  2>&1 | head -1 ;;
        cargo)      "$cmd" --version  2>&1 | head -1 ;;
        python3)    "$cmd" --version  2>&1 | head -1 ;;
        bob)        "$cmd" --version  2>&1 | head -1 ;;
        starship)   "$cmd" --version  2>&1 | head -1 ;;
        atuin)      "$cmd" --version  2>&1 | head -1 ;;
        git-lfs)    "$cmd" version    2>&1 | head -1 ;;
        *)          echo "" ;;
    esac
}

# ---------------------------------------------------------------------------
# special-case detections
# ---------------------------------------------------------------------------
_check_nvm() {
    [[ -d "${NVM_DIR:-$HOME/.nvm}" ]]
}

_check_trash() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        command -v trash &>/dev/null
    else
        command -v trash-put &>/dev/null
    fi
}

# ---------------------------------------------------------------------------
# tool lists
# ---------------------------------------------------------------------------
MUST_HAVE_CMDS=(
    "tmux"          # terminal multiplexer
    "nvim"          # editor
    "bob"           # neovim version manager
    "go"            # golang
    "node"          # node.js
    "npm"           # node package manager
    "yarn"          # node package manager (alt)
    "cargo"         # rust package manager
    "rg"            # ripgrep - grep alternative, used in fzf
    "fzf"           # fuzzy finder
    "bat"           # cat alternative, used as pager
    "starship"      # prompt
    "atuin"         # shell history
    "git-lfs"       # git large file storage
    "shellcheck"    # shell script linter
)

NICE_TO_HAVE_CMDS=(
    "pyenv"         # python version manager
    "deno"          # deno runtime
    "goimports"     # go import management
    "prettier"      # js/html/json formatter
    "eslint"        # js linter
    "shfmt"         # shell formatter
    "eza"           # ls alternative (maintained exa fork)
    "procs"         # ps alternative
    "tldr"          # cheatsheets
    "duf"           # df alternative
    "gping"         # ping alternative
    "entr"          # run cmd on file change
    "sqlite3"       # sqlite cli
    "luacheck"      # lua linter (for neovim config)
    "lazygit"       # terminal ui for git
    "delta"         # better git diff pager
    "jq"            # json processor
    "zoxide"        # smarter cd
    "btop"          # system monitor
    "yazi"          # terminal file manager
)

SPECIAL_CHECKS=(
    "nvm:_check_nvm"
    "trash:_check_trash"
)

# ---------------------------------------------------------------------------
# check runner
# ---------------------------------------------------------------------------
_check_cmds() {
    local -a missing_must=()
    local -a missing_nice=()
    local -a ok_must=()
    local -a ok_nice=()

    for cmd in "${MUST_HAVE_CMDS[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            ok_must+=("$cmd")
        else
            missing_must+=("$cmd")
        fi
    done

    for cmd in "${NICE_TO_HAVE_CMDS[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            ok_nice+=("$cmd")
        else
            missing_nice+=("$cmd")
        fi
    done

    local -a ok_special=()
    local -a missing_special=()
    for entry in "${SPECIAL_CHECKS[@]}"; do
        local label="${entry%%:*}"
        local fn="${entry##*:}"
        if "$fn"; then
            ok_special+=("$label")
        else
            missing_special+=("$label")
        fi
    done

    echo ""
    _bold "=== dotfiles check ==="; echo ""
    echo "os: $OSTYPE"
    echo ""

    _bold "must-have (installed):"; echo ""
    if [[ ${#ok_must[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for cmd in "${ok_must[@]}"; do
            local ver
            ver=$(_get_version "$cmd")
            if [[ -n "$ver" ]]; then
                printf '  %s  %s\n' "$(_green "✓ $cmd")" "$(_yellow "$ver")"
            else
                printf '  %s\n' "$(_green "✓ $cmd")"
            fi
        done
    fi
    echo ""

    _bold "nice-to-have (installed):"; echo ""
    if [[ ${#ok_nice[@]} -eq 0 && ${#ok_special[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for cmd in "${ok_nice[@]}" "${ok_special[@]}"; do
            printf '  %s\n' "$(_green "✓ $cmd")"
        done
    fi
    echo ""

    if [[ ${#missing_must[@]} -gt 0 || ${#missing_special[@]} -gt 0 ]]; then
        _bold "must-have ($(_red "MISSING")):"; echo ""
        for cmd in "${missing_must[@]}"; do
            printf '  %s\n' "$(_red "✗ $cmd")"
        done
        for cmd in "${missing_special[@]}"; do
            printf '  %s\n' "$(_red "✗ $cmd")"
        done
        echo ""
    fi

    if [[ ${#missing_nice[@]} -gt 0 ]]; then
        _bold "nice-to-have (not installed):"; echo ""
        for cmd in "${missing_nice[@]}"; do
            printf '  %s\n' "$(_yellow "- $cmd")"
        done
        echo ""
    fi

    local total_must=$(( ${#MUST_HAVE_CMDS[@]} + ${#SPECIAL_CHECKS[@]} ))
    local ok_total=$(( ${#ok_must[@]} + ${#ok_special[@]} ))
    local missing_total=$(( ${#missing_must[@]} + ${#missing_special[@]} ))

    _bold "summary: "
    if [[ $missing_total -eq 0 ]]; then
        _green "all must-haves installed ($ok_total/$total_must)"
    else
        _red "$missing_total/$total_must must-haves missing"
    fi
    echo -e "\n"

    [[ $missing_total -eq 0 ]]
}

_check_cmds

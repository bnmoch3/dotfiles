#!/usr/bin/zsh
# auto virtual environment activation
# automatically activates python virtual environments when entering project dirs

# load hook system if not already loaded
autoload -U add-zsh-hook

auto_venv_activate() {
    # performance optimization: if we're already in a subdirectory of the
    # current active venv, skip
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_project_root="$(dirname "$VIRTUAL_ENV")"
        if [[ "$PWD" == "$venv_project_root"* ]]; then
            return
        fi
    fi

    # find .venv in current directory or any parent directory
    # walks up the directory tree from $PWD looking for .venv/bin/activate
    local venv_path=""
    local search_dir="$PWD"
    while [[ "$search_dir" != "/" ]]; do
        if [[ -f "$search_dir/.venv/bin/activate" ]]; then
            venv_path="$search_dir/.venv"
            break
        fi
        search_dir="$(dirname "$search_dir")"
    done

    # only activate if we found a venv AND it's different from current active
    if [[ -n "$venv_path" && "$VIRTUAL_ENV" != "$venv_path" ]]; then
        # runs deactivate only if necessary
        # saves and restores PS1 to prevent the prompt from being blanked or
        # malformed after a deactivate
        if [[ -n "$VIRTUAL_ENV" ]]; then
            local saved_ps1="$PS1"
            deactivate 2>/dev/null
            PS1="$saved_ps1"
        fi

        # activate new venv
        if source "$venv_path/bin/activate" 2>/dev/null; then
            echo "🐍 Activated venv: $(basename "$(dirname "$venv_path")")"
        else
            echo "⚠️Failed to activate venv: $venv_path" >&2
        fi
    fi

    # safe prompt refresh - only if ZLE is active AND we're in interactive mode
    # avoids the bug: "widgets can only be called when ZLE is active"
    if [[ -o zle && -o interactive ]] && zle -l >/dev/null 2>&1; then
        zle reset-prompt 2>/dev/null  # much safer
    fi
}

# add zsh hook chpwd auto_venv_activate which triggers the function on every cd
add-zsh-hook chpwd auto_venv_activate

# ensure venv is activated on shell launch if .venv exists in the CWD
# defers until after the prompt system (eg. starship) has initialized
auto_venv_startup() {
    if [[ -f .venv/bin/activate ]]; then
        auto_venv_activate
    fi
}
add-zsh-hook precmd auto_venv_startup

# remove the startup hook after first run
# prevents unnecessary re-evaluation and keeps shell lean
_remove_startup_hook() {
    add-zsh-hook -d precmd auto_venv_startup
    add-zsh-hook -d precmd _remove_startup_hook
}
add-zsh-hook precmd _remove_startup_hook

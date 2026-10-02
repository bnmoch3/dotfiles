#!/usr/bin/env bash

set -euo pipefail

session_dir=${2:-"$PWD"}
session_name=${1:-$(basename "$session_dir")}

if [[ ! -d "$session_dir" ]]; then
    echo "Directory does not exist: $session_dir" >&2
    exit 1
fi

if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "tmux session already exists: $session_name" >&2
    exit 1
fi

# Prevent a newly created tmux session from inheriting an active Python venv.
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    if type deactivate >/dev/null 2>&1; then
        deactivate
    else
        PATH="${PATH#${VIRTUAL_ENV}/bin:}"
        unset VIRTUAL_ENV PYTHONHOME _OLD_VIRTUAL_PATH _OLD_VIRTUAL_PYTHONHOME
    fi
fi

echo "creating session '$session_name' in '$session_dir'"

tmux new-session \
    -d \
    -s "$session_name" \
    -n main \
    -c "$session_dir"

# Switch if we're genuinely inside a tmux client.
if [[ -n "${TMUX:-}" ]] && tmux display-message -p '#S' &>/dev/null; then
    tmux switch-client -t "$session_name"
else
    exec tmux attach-session -t "$session_name"
fi

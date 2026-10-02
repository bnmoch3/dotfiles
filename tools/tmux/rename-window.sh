#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${TMUX:-}" ]] || ! tmux display-message -p '#S' &>/dev/null; then
    echo "rename-window: must be run inside a tmux session" >&2
    exit 1
fi

current_name=$(tmux display-message -p '#{window_name}')

if [[ $# -gt 0 ]]; then
    new_name=$1
else
    read -r -p "window name [$current_name] > " new_name
    new_name=${new_name:-"$current_name"}
fi

[[ -z "$new_name" ]] && exit 0

tmux rename-window "$new_name"

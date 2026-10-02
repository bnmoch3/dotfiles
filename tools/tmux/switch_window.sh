#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${TMUX:-}" ]] || ! tmux display-message -p '#S' &>/dev/null; then
    echo "switch_window: must be run inside a tmux session" >&2
    exit 1
fi

current_window=$(tmux display-message -p '#{window_index}')

rows=""

while IFS= read -r index; do
    name=$(tmux display-message -p -t ":$index" '#{window_name}')

    if [[ "$index" == "$current_window" ]]; then
        marker="*"
    else
        marker=" "
    fi

    display=$(printf "%s %2s  %s" "$marker" "$index" "$name")
    rows+="$index"$'\t'"$display"$'\n'
done < <(tmux list-windows -F '#{window_index}')

selection=$(
    printf '%s' "$rows" |
        fzf \
            --no-multi \
            --delimiter=$'\t' \
            --with-nth=2 \
            --prompt='tmux window > ' \
            --height=100% \
            --layout=reverse \
            --border \
            --info=inline \
            --pointer='>'
)

[[ -z "$selection" ]] && exit 0

window_index=${selection%%$'\t'*}

tmux select-window -t ":$window_index"

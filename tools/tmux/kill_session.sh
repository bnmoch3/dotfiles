#!/usr/bin/env bash

set -euo pipefail

if ! tmux list-sessions &>/dev/null; then
    echo "kill_session: no tmux sessions" >&2
    exit 1
fi

current_session=""

if [[ -n "${TMUX:-}" ]] && tmux display-message -p '#S' &>/dev/null; then
    current_session=$(tmux display-message -p '#S')
fi

rows=""

while IFS= read -r session; do
    if [[ "$session" == "$current_session" ]]; then
        marker="*"
    else
        marker=" "
    fi

    display=$(printf "%s %s" "$marker" "$session")
    rows+="$session"$'\t'"$display"$'\n'
done < <(tmux list-sessions -F '#{session_name}')

selection=$(
    printf '%s' "$rows" |
        fzf \
            --no-multi \
            --delimiter=$'\t' \
            --with-nth=2 \
            --prompt='kill session > ' \
            --height=100% \
            --layout=reverse \
            --border \
            --info=inline \
            --pointer='>'
)

[[ -z "$selection" ]] && exit 0

session=${selection%%$'\t'*}

tmux kill-session -t "$session"

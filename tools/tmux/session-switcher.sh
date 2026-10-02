#!/usr/bin/env bash

set -euo pipefail

if ! tmux list-sessions &>/dev/null; then
    echo "No tmux sessions."
    exit 0
fi

if [[ -n "${TMUX:-}" ]]; then
    current_session=$(tmux display-message -p '#S')
else
    current_session=""
fi

rows=""

while IFS= read -r session; do
    window_count=$(tmux list-windows -t "$session" -F '#{window_id}' | wc -l | tr -d ' ')
    windows=$(tmux list-windows -t "$session" -F '#{window_name}' | paste -sd ',' -)

    if [[ "$session" == "$current_session" ]]; then
        marker="*"
    else
        marker=" "
    fi

    display=$(printf "%s %-28s %2s windows   %s" \
        "$marker" \
        "$session" \
        "$window_count" \
        "$windows")

    rows+="$session"$'\t'"$display"$'\n'
done < <(tmux list-sessions -F '#{session_name}')

selection=$(
    printf '%s' "$rows" |
        fzf \
            --no-multi \
            --delimiter=$'\t' \
            --with-nth=2 \
            --prompt='tmux session > ' \
            --height=100% \
            --layout=reverse \
            --border \
            --info=inline \
            --pointer='>'
)

[[ -z "$selection" ]] && exit 0

session=${selection%%$'\t'*}

if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session"
else
    tmux attach-session -t "$session"
fi

#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/toggle-terminal-prev-window"
ALACRITTY_CLASS="Alacritty.Alacritty"

mapfile -t alacritty_windows < <(
    wmctrl -lx |
        awk '$3 == "Alacritty.Alacritty" { print $1 }'
)

# No Alacritty window exists: launch one.
if ((${#alacritty_windows[@]} == 0)); then
    alacritty >/dev/null 2>&1 &
    exit 0
fi

# There may be no currently focused normal window.
active_id="$(xdotool getactivewindow 2>/dev/null || true)"

if [[ -z "$active_id" ]]; then
    wmctrl -ia "${alacritty_windows[0]}"
    exit 0
fi

active_hex="$(printf '0x%08x' "$active_id")"

active_class="$(
    xprop -id "$active_id" WM_CLASS 2>/dev/null || true
)"

# Currently in Alacritty: return to the previous non-Alacritty window.
if [[ "$active_class" == *"Alacritty"* ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        previous_id="$(cat "$STATE_FILE")"

        if wmctrl -l |
            awk '{ print $1 }' |
            grep -Fxq "$previous_id"; then
            wmctrl -ia "$previous_id"
        fi
    fi

    exit 0
fi

# Currently outside Alacritty: remember this window.
printf '%s\n' "$active_hex" >"$STATE_FILE"

# Focus an existing Alacritty window.
wmctrl -ia "${alacritty_windows[0]}"

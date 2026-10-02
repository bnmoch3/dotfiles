#!/usr/bin/env bash

set -u

"$@"
status=$?

if [[ $status -ne 0 ]]; then
    echo
    echo "$(basename "$1") failed with status $status"
    echo
    read -r -p "Press Enter to close..."
fi

exit "$status"

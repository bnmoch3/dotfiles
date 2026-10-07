#!/usr/bin/zsh

# interactive fuzzy find and open with nvim
nv() {
	nvim "$(fzf -m)"
}

# copy cwd to clipboard
pwdd() {
	case "$OSTYPE" in
		linux-gnu*) pwd | xclip -i ;;
		darwin*)    pwd | pbcopy ;;
		*)          echo "pwdd: unsupported OS $OSTYPE" ;;
	esac
}

# change directory from clipboard
cwdd() {
	local dir
	case "$OSTYPE" in
		linux-gnu*) dir=$(xclip -o) ;;
		darwin*)    dir=$(pbpaste) ;;
		*)          echo "cwdd: unsupported OS $OSTYPE"; return 1 ;;
	esac

	if [[ -d $dir ]]; then
		cd "$dir" || return 1
	else
		echo "cwdd: '$dir' is not a directory"
	fi
}

# soft delete files
del() {
	case "$OSTYPE" in
		linux-gnu*) trash-put "$@" ;;
		darwin*)    trash "$@" ;;
		*)          echo "del: unsupported OS $OSTYPE"; return 1 ;;
	esac
}

# open file/directory
open() {
	case "$OSTYPE" in
		linux-gnu*) xdg-open "$1" ;;
		darwin*)    /usr/bin/open "$1" ;;
		*)          echo "open: unsupported OS $OSTYPE"; return 1 ;;
	esac
}

# activate Python venv
activate() {
	if [[ -f .venv/bin/activate ]]; then
		source .venv/bin/activate
	else
		echo "activate: .venv/bin/activate not found"
	fi
}

# find files at top level of directory
find1() {
    local dir=
    if [[ $# -gt 0 && "$1" != -* ]]; then
      dir=$1
      shift
    fi
    find "${dir:-.}" -maxdepth 1 "$@"
}


chatgpt() {
    (
        cd "$HOME/PROJECTS/.scratch/codex" || return 1
        exec codex --model gpt-5.6-luna
    )
}

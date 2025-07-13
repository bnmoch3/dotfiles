#!/usr/bin/zsh

# interactive fuzzy find and open with nvim
nv() {
	nvim "$(fzf -m)"
}

# start or attach to a tmux session
tms() {
	local session_name
	if [[ -z $1 ]]; then
		read "session_name?tmux session name: "
		if [[ -z $session_name ]]; then
			session_name=$(basename "$PWD")
		fi
	else
		session_name=$1
	fi

	if ! tmux has-session -t "$session_name" 2>/dev/null; then
		tmux new-session -d -s "$session_name" -n 'main'
	fi

	if [[ -n $TMUX ]]; then
		tmux switch -t "$session_name"
	else
		tmux attach -t "$session_name"
	fi
}

# rename tmux window
tmr() {
	local window_name=${1:-main}
	if [[ -n $TMUX ]]; then
		tmux rename-window -t 1 "$window_name"
	fi
}

# kill tmux session chosen via fzf
tmk() {
	tmux kill-session -t "$(tmux ls -F '#{session_name}' | fzf)"
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

# adjust redshift color temp
nightmode() {
	[[ "$OSTYPE" == linux-gnu* ]] && redshift -x && redshift -o -O 1500
}

daymode() {
	[[ "$OSTYPE" == linux-gnu* ]] && redshift -x
}

# quick open TODO
todo() {
	nvim "$HOME/TODO.txt"
}

hello_world() {
  echo "hello zsh"
}

#!/usr/bin/bash

function nv() {
	nvim "$(fzf -m)"
}

function tms() {
	# session name can either be passed as arg or prompted for
	# if input session is blank, cwd base is used as the session name
	if [[ -z $1 ]]; then
		echo -n "tmux session name: "
		read session_name
		if [[ -z $session_name ]]; then
			session_name=$(basename "$(pwd)")
		fi
	fi

	# create session if does not exist
	tmux has-session -t $session_name 2>/dev/null
	if [[ $? != 0 ]]; then
		tmux new-session -d -s $session_name -n 'main'
	fi

	# switch to session
	if [[ -n $TMUX ]]; then
		tmux switch -t $session_name
	else
		tmux attach -t $session_name
	fi
}

function tmr() {
	window_name='main'
	if [[ -n $1 ]]; then
		window_name=$1
	fi
	if [[ -n $TMUX ]]; then
		tmux rename-window -t 1 $window_name
	fi
}

function tmk() {
	tmux kill-session -t "$(tmux ls -F '#{session_name}' | fzf)"
}

# copy cwd to system clipboard
function pwdd() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		pwd | xclip -i
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		pwd | pbcopy
	else
		echo "pwdd function not define for $OSTYPE"
		return 1
	fi
}

# cd to path in system clipboard
function cwdd() {
	local dir
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		dir=$(xclip -o)
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		dir=$(pbpaste)
	else
		echo "pwdd function not define for $OSTYPE"
		return 1
	fi
	if [[ -d $dir ]]; then
		cd $dir || return 1
	fi
}

# soft delete for files
function del() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		trash-put "$@"
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		trash "$@"
	else
		echo "open function not define for $OSTYPE"
		return 1
	fi
}

function open() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		xdg-open $1
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		/usr/bin/open $1
	else
		echo "open function not define for $OSTYPE"
		return 1
	fi
}

function activate() {
	if [[ -f .venv/bin/activate ]]; then
		source .venv/bin/activate
	else
		echo "virtual .venv/bin/activate does not exist"
		return 1
	fi
}

function find1() {
	dir=
	if [[ ! "$1" =~ ^-.* ]]; then
		dir=$1
		shift
	fi
	find $dir -maxdepth 1 "$@"
}

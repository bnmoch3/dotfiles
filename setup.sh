#!/bin/bash

# exit when any command fails
set -e

_add_dotfile() {
	local dotfile=$1
	local dest_dir=$2
	local prefix=$3

	local dest
	dest=$dest_dir/$prefix$(basename "$dotfile")

	if [[ $OVERWRITE == 0 ]]; then
		echo "info add $dotfile -> $dest"
	else
		echo "info overwriting $dotfile -> $dest"
	fi
	[[ $DRY_RUN != 0 ]] && return

	# check that dotfile exists
	dotfile=$(realpath $dotfile)
	if [[ ! -f "$dotfile" ]]; then
		echo "error $dotfile file does not exist"
		exit 1
	fi

	# check that destination is a directory and exists
	if [[ ! -d "$dest_dir" ]]; then
		echo "error $dest_dir directory does not exist"
		exit 1
	fi

	if [[ $OVERWRITE == 0 ]]; then
		ln -s "$dotfile" "$dest"
	else
		ln -s -f "$dotfile" "$dest"
	fi
}

_add_dotfile_basic() {
	_add_dotfile "$1" "$HOME" "."
}

_setup_local_bin() {
	# print out bin path
	echo "info bin path: $BIN_PATH"

	# check if path contains BIN_PATH
	if [[ ":$PATH:" == *":$BIN_PATH:"* ]]; then
		echo "info path contains $BIN_PATH"
	else
		echo "warn path does NOT contain $BIN_PATH"
		# echo "info add $BIN_PATH to PATH temporarily"
		# PATH=$BIN_PATH:$PATH
	fi

	# create bin path if does not exist
	if [[ ! -d $BIN_PATH ]]; then
		echo "info mkdir $BIN_PATH"
		[[ $DRY_RUN == 0 ]] && mkdir -p "$BIN_PATH"
	fi

}

_setup_dotfiles() {
	_add_dotfile_basic alacritty.yml
	_add_dotfile_basic bash/bashrc
	_add_dotfile_basic git/gitconfig
	_add_dotfile_basic git/gitignore
	_add_dotfile_basic inputrc
	_add_dotfile_basic nvim/vimrc
	_add_dotfile nvim/init.lua "$HOME/.config/nvim" ""
	_add_dotfile_basic psqlrc
	_add_dotfile_basic sqliterc
	_add_dotfile_basic tmux.conf
}

setup() {
	_setup_local_bin
	_setup_dotfiles
}

usage() {
	echo "usage: $0 [-h | --help] [-n | --dry-run] [-b | --bin-dir <path>]"
	echo "sets up my configs and tools"
	echo "opts:"
	cat <<-_EOF_
		    -h, --help              display help and exit
		    -n, --dry-run           display actions that would have been done
		    -p, --bin-path <path>   set path to install local binaries
		    -o, --overwrite         overwrite dotfile, by default set up fails if dotfile already exists in HOME
	_EOF_
	return
}

DRY_RUN=0
BIN_PATH=$HOME/LOCAL/bin
OVERWRITE=0

while [[ -n "$1" ]]; do
	case "$1" in
	-n | --dry-run)
		DRY_RUN=1
		;;
	-o | --overwrite)
		OVERWRITE=1
		;;
	-h | --help)
		usage
		exit
		;;
	-b | --bin-path)
		shift
		BIN_PATH="$1"
		if [[ ! -d "$BIN_PATH" && $DRY_RUN == 0 ]]; then
			echo "Invalid directory path: $BIN_PATH" >&2
			exit 1
		fi
		;;
	*)
		usage >&2
		exit 1
		;;
	esac
	shift
done

setup

#!/usr/bin/env bash

_check_cmds() {
	local check_must_install=(tmux nvim go node npm yarn cargo
		rg fzf patdiff bat shellcheck)
	local check_nice_to_have=(pyenv goimports prettier eslint shfmt)

	local installed=()
	local must_install=()
	local nice_to_have=()

	for cmd in ${check_must_install[*]}; do
		if command -v $cmd &>/dev/null; then
			installed+=("$cmd")
		else
			must_install+=("$cmd")
		fi
	done

	for cmd in ${check_nice_to_have[*]}; do
		if command -v $cmd &>/dev/null; then
			installed+=("$cmd")
		else
			nice_to_have+=("$cmd")
		fi
	done

	echo "installed:"
	for cmd in ${installed[*]}; do
		echo -e "\t$cmd"
	done
	echo -e "\n"

	echo "nice to have:"
	for cmd in ${nice_to_have[*]}; do
		echo -e "\t$cmd"
	done
	echo -e "\n"

	echo "must install:"
	for cmd in ${must_install[*]}; do
		echo -e "\t$cmd"
	done
	echo -e "\n"
}

_check_cmds

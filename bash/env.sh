#!/usr/bin/bash

if ! command -v "nvim" >/dev/null; then
	EDITOR="nvim"
else
	EDITOR="vi"
fi

export PSQL_EDITOR=$EDITOR

# pager, use bat if present
if ! command -v bat >/dev/null; then
	export PAGER=bat
fi

if [[ -z "$TMUX" ]]; then
	export TERM=xterm-256color
fi

# FZF options
if type rg &>/dev/null; then
	export FZF_DEFAULT_COMMANND='rg --files'
	export FZF_DEFAULT_OPTS='-m'
fi

export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --margin=1 --padding=1'

# yarn
if command -v yarn &>/dev/null; then
	yarn_bin=$(yarn global bin)
	PATH=$PATH:$yarn_bin
fi

# go
if command -v go &>/dev/null; then
	PATH=$PATH:/usr/local/go/bin/:home/bnm/go/bin
fi

if command -v pyenv &>/dev/null; then
	export PYENV_ROOT="$HOME/.pyenv"
	eval "$(pyenv init -)"
fi

# PATH="$PATH:/home/bnm/installed/bin:/home/bnm/installed/bin/SQLiteStudio/"
if [[ -d "$HOME/dotfiles" ]]; then
    PATH="$HOME/bin:$PATH"
fi


export PATH

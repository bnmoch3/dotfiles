#!/usr/bin/bash

if command -v "nvim" >/dev/null; then
	EDITOR="nvim"
else
	EDITOR="vim"
fi

export PSQL_EDITOR=$EDITOR

# pager, use bat if present
if command -v bat >/dev/null; then
	export PAGER=bat
fi

# FZF options
if type rg &>/dev/null; then
	export FZF_DEFAULT_COMMANND='rg --files'
	export FZF_DEFAULT_OPTS='-m'
fi

export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --margin=1'

if [[ -f $HOME/.fzf.bash ]]; then
	source "$HOME/.fzf.bash"
fi

# yarn
if command -v yarn &>/dev/null; then
	yarn_bin=$(yarn global bin)
	PATH=$PATH:$yarn_bin
fi

# go
if [[ -d /usr/local/go ]]; then
	PATH=$PATH:/usr/local/go/bin
	PATH=$PATH:$(go env GOPATH)/bin
fi

# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
	export PYENV_ROOT="$HOME/.pyenv"
	PATH=$PATH:$PYENV_ROOT/bin
	eval "$(pyenv init -)"
fi

# source cargo
if [[ -f "$HOME/.cargo/env" ]]; then
	. "$HOME/.cargo/env"
fi

# # opam configuration
if [[ -f $HOME/.opam/opam-init/init.sh ]]; then
	. $HOME/.opam/opam-init/init.sh
fi

# PATH="$PATH:/home/bnm/installed/bin:/home/bnm/installed/bin/SQLiteStudio/"
if [[ -d "$HOME/dotfiles" ]]; then
	PATH="$HOME/.local/bin:$PATH"
fi

export PATH

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

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # nvm bash_completion

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

# zig
if [[ -d "$HOME/LOCAL/pkg/zig" ]]; then
	PATH=$PATH:$HOME/LOCAL/pkg/zig
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

# encore
export ENCORE_INSTALL="/home/bnm/.encore"
PATH="$ENCORE_INSTALL/bin:$PATH"

if [[ -d "$HOME/LOCAL/bin" ]]; then
	PATH="$HOME/LOCAL/bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
	PATH="$HOME/.local/bin:$PATH"
fi

# erlang
. /usr/local/lib/erlang/26.2.4/activate

# elixir
PATH="/$HOME/LOCAL/pkg/elixir-1.16.2/bin:$PATH"

# cuda
PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-12.3/lib64:$LD_LIBRARY_PATH"

export PATH

#!/usr/bin/bash

if command -v "nvim" >/dev/null; then
    EDITOR="nvim"
else
    EDITOR="vim"
fi

export PSQL_EDITOR=$EDITOR

export MANPAGER='nvim +Man!'

# pager, use bat if present
if command -v bat >/dev/null; then
    export PAGER=bat
fi

# FZF options
# FZF options
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --margin=1 -m'

if type rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
fi

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

# source cargo
if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

# # opam configuration
if [[ -f $HOME/.opam/opam-init/init.sh ]]; then
    . $HOME/.opam/opam-init/init.sh
fi

# local bin
if [[ -d "$HOME/LOCAL/bin" ]]; then
    PATH="$HOME/LOCAL/bin:$PATH"
fi

# local bin
if [[ -d "$HOME/.local/bin" ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# cuda
# cuda (linux only)
[[ -d "/usr/local/cuda/bin" ]] && PATH="/usr/local/cuda/bin:$PATH"
[[ -d "/usr/local/cuda-12.3/lib64" ]] && export LD_LIBRARY_PATH="/usr/local/cuda-12.3/lib64:$LD_LIBRARY_PATH"

export VCPKG_ROOT="$HOME/LOCAL/bin/vcpkg"

export PATH

#! /usr/bin/bash
# Aliases

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# soft delete for files
alias del='trash-put'
alias trash='trash-put'

# some more ls aliases
alias ll='ls -alF'
alias l1='ls -1'

alias pwdd='pwd | xclip -i'
alias cwdd='cd $(xclip -o)'

alias activate="source .venv/bin/activate"

alias open=xdg-open

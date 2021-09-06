#!/usr/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt


PS1="\[\033[0;32m\][\h\$]\W:\[\033[0m\] "

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# file limits for Pilosa
ulimit -n 262144
ulimit -u 2048

# by default, terminal uses emacs keystrokes for editing commands, instead use vim keystrokes
set -o vi


# psql editor
# check out: https://simply.name/yet-another-psql-color-prompt.html
export PSQL_EDITOR="nvim"

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable go get for private repos
export GOPRIVATE="github.com/molecula"

# Go language
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/bnm/go/bin

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PATH:$(yarn global bin)"

# Alias definitions.
if [ -f "$HOME/dotfiles/.bash_aliases" ]; then
    . "$HOME/dotfiles/.bash_aliases"
fi

# Function definitions.
if [ -f "$HOME/dotfiles/.bash_functions.sh" ]; then
    . "$HOME/dotfiles/.bash_functions.sh"
fi


[ -z "$TMUX" ] && export TERM=xterm-256color

# if command -v most > /dev/null 2>&1; then
#     export PAGER="most"
# fi
. "$HOME/.cargo/env"


# Enhance cd to use other dirs instead of just the current dir
# Credits: https://mhoffman.github.io/2015/05/21/how-to-navigate-directories-with-the-shell.html
# CDPATH=.:~:~/PROJECTS:~/MOLECULA


# FZF options
if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMANND='rg --files'
    export FZF_DEFAULT_OPTS='-m'
fi

export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --margin=1 --padding=1'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash



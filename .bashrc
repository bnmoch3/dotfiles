# enable grep to use colors
export GREP_OPTIONS='--color=auto'

# enable ls to use colors
export CLICOLOR=1
# export LSCOLORS=HxDxDxdxbxdhdhbababAbA
export LSCOLORS=DxDxDxdxbxdhdhbababAbA

# color prompt
#PS1='\[\e[36;1m\u@\h|\e[36m\W $:\e[0m\] '
cyan=$(tput setaf 10) # \e[36m
bold=$(tput bold)
reset=$(tput sgr0)   # \e[0m
PS1='\[$cyan$bold\]\n\W $: \[$reset\]'

# psql editor
# check out: https://simply.name/yet-another-psql-color-prompt.html
export PSQL_EDITOR="code -w"


# file limits for Pilosa
ulimit -n 262144
ulimit -u 2048



# by default, terminal uses emacs keystrokes for editing commands, instead use vim keystrokes
set -o vi


# enable go get for private repos
export GOPRIVATE="github.com/molecula"

# Go language
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/bnm/go/bin

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PATH:$(yarn global bin)"




# Alias definitions.

if [ -f ~/Config/.bash_aliases ]; then
    . ~/Config/.bash_aliases
fi

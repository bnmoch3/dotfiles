# enable grep to use colors
export GREP_OPTIONS='--color=auto'

# enable ls to use colors
export CLICOLOR=1
export LSCOLORS=HxDxDxdxbxdhdhbababAbA

# color prompt
#PS1='\[\e[36;1m\u@\h|\e[36m\W $:\e[0m\] '
cyan=$(tput setaf 10) # \e[36m
bold=$(tput bold)
reset=$(tput sgr0)   # \e[0m
PS1='\[$cyan$bold\]\n\u@\h [\@] \w\n$: \[$reset\]'

# psql editor
# check out: https://simply.name/yet-another-psql-color-prompt.html
export PSQL_EDITOR="vim"

# soft delete for files
alias del = 'mv ~/.Trash'

# use vim keystrokes to edit commands
set -o vi


# PATHs
export PATH="$PATH:$(yarn global bin)"
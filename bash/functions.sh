#!/usr/bin/bash

function nv() {
    nvim "$(fzf -m)"
}

# copy cwd to system clipboard
function pwdd() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pwd | xclip -i
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        pwd | pbcopy
    else
        echo "pwdd function not define for $OSTYPE"
        return 1
    fi
}

# cd to path in system clipboard
function cwdd() {
    local dir
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        dir=$(xclip -o)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        dir=$(pbpaste)
    else
        echo "pwdd function not define for $OSTYPE"
        return 1
    fi
    if [[ -d $dir ]]; then
        cd $dir || return 1
    fi
}

# soft delete for files
function del() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        trash-put "$@"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        trash "$@"
    else
        echo "open function not define for $OSTYPE"
        return 1
    fi
}

function open() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open $1
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        /usr/bin/open $1
    else
        echo "open function not define for $OSTYPE"
        return 1
    fi
}

function activate() {
    if [[ -f .venv/bin/activate ]]; then
        source .venv/bin/activate
    else
        echo "virtual .venv/bin/activate does not exist"
        return 1
    fi
}

function find1() {
    dir=
    if [[ ! "$1" =~ ^-.* ]]; then
        dir=$1
        shift
    fi
    find $dir -maxdepth 1 "$@"
}

function daymode() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        redshift -x
    fi
}

function todo() {
    nvim "$HOME/TODO.txt"
}

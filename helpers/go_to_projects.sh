#! /usr/bin/env bash
# File: projects.sh





function projects {
    # Provide only 1 argument, the directory within
    # projects that you want to go to
    if [[ $# = 0 ]]
    then
        echo "Provide an argument"
        exit 1
    elif [[ $# -gt 1 ]] 
    then
        echo "Invalid number of arguments"
        exit 1
    fi


    local projects_dir="$HOME/Desktop/PROJECTS/$1"
    if [[ ! -d "$projects_dir" ]]
    then
        echo "$projects_dir does not exist"
        exit 1
    fi

    cd "$projects_dir" 

}

export -f projects

#!/usr/bin/bash

function edit-files() {
    fzf --multi | xargs --no-run-if-empty -I{} nvim {} 
}

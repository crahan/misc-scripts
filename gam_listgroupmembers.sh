#!/bin/sh
alias gam='python ~/.gam/gam.py'

for group in `gam print groups | sed 's/,//' | grep @`; do
    gam info group $group
    echo "\n---------------\n"
done

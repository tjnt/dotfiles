#!/bin/bash
# used to delete clipboard history from xmonad.
fzf=~/.zplug/bin/fzf
export FZF_DEFAULT_OPTS='--layout=reverse --border --inline-info'
recid=$(clipc --list | $fzf | awk '{print $1}')
[[ -n $recid ]] \
    && clipc --delete $recid

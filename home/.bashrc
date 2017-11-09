#!/bin/bash

# if this shell isn't interactive, bail out
[[ $- != *i* ]] && return

# Source global definitions
[[ -f "/etc/bashrc" ]] && . "/etc/bashrc"

# set up path
export PATH=$PATH:$HOME/bin

# infinite history
export HISTSIZE=""

#pager
export LESS="-RFXS"
export PAGER="less"

# dircolors
eval "$(dircolors -b)"

# aliases
alias gup='git fetch && git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gl='git log --graph --all --pretty="%Cgreen%h %Cred%an: %Creset%s"'
alias noeol="perl -pi -e 'chomp if eof'"
alias mkdir="mkdir -p"
alias grep="grep --color=auto"
alias ls="ls -hF --color=auto"

# VAM-specific env vars
[[ $HOSTNAME =~ ^vam[0-9]+\. ]] && . "$HOME/.bash/vamhost.bashrc"

# local bashrc (if any)
[[ -e "$HOME/.bash/localrc/${HOSTNAME}.bashrc" ]] && . "$HOME/.bash/localrc/${HOSTNAME}.bashrc"

# homeshick
. "$HOME/.homesick/repos/homeshick/homeshick.sh"

# mini scripts
. ~/.bash/miniscripts.sh

# shell prompt
. ~/.bash/prompt/vexing.sh

return 0

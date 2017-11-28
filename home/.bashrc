#!/bin/bash

# if this shell isn't interactive, bail out
[[ $- != *i* ]] && return

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

# set up path
export PATH=$PATH:$HOME/bin:/usr/local/sbin:/usr/sbin:/sbin

#pager
export LESS=-RFXS
export PAGER=less

# dircolors
eval "$(dircolors -b)"


# VAM-specific env vars
[[ $HOSTNAME =~ ^vam[0-9]+\. ]] && . "$HOME/.bash/vamhost.bashrc"

# local bashrc (if any)
[[ -e "$HOME/.bash/localrc/${HOSTNAME}.bashrc" ]] && . "$HOME/.bash/localrc/${HOSTNAME}.bashrc"

# homeshick
. "$HOME/.homesick/repos/homeshick/homeshick.sh"

# mini scripts
. ~/.bash/miniscripts.sh

# shell prompt
PS1='$? \w \$ '
. ~/.bash/prompt/vexing.sh

# history settings
export HISTSIZE=
shopt -s histappend

[[ ! -z $PROMPT_COMMAND ]] && OLDPC="${PROMPT_COMMAND}; "
PROMPT_COMMAND="${OLDPC}history -a; history -n"


return 0

#!/bin/bash

case $- in
    *i*) ;;
      *) return;;
esac

# external stuff
eval "$(dircolors -b)"
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
source ~/.bashrc.private
source ~/.bashrc.prompt

# bash completions

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# OpenSpec shell completions configuration
if [ -d "/home/slaufer/.local/share/bash-completion/completions" ]; then
  for f in "/home/slaufer/.local/share/bash-completion/completions"/*; do
    [ -f "$f" ] && . "$f"
  done
fi


# shell opts
shopt -s checkwinsize
shopt -s histappend


# env vars
export LESS=-RFXS
export PAGER=less
export HISTSIZE=
export HISTCONTROL=ignoreboth
export HISTFILESIZE=
export HISTFILE=$HOME/.bash_history
export EDITOR=nvim


# aliases (duh)
alias ls='ls -h --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vim='nvim'
alias gl='git log --graph --pretty="%Cgreen%h %Cblue%cr %Cred%an: %Creset%s"'
alias vea='[ -x venv ] && . venv/bin/activate || . .venv/bin/activate'
alias vec='python -m venv venv'
alias nohist='export HISTFILE='
alias ffpp='ffplay -autoexit -nodisp -v quiet'
alias startx='exec `which startx`'

if command -v xsel > /dev/null; then
  alias cb="xsel -ib"
elif command -v xclip > /dev/null; then
  alias cb="xclip -i -selection clipboard"
fi

bad() {
  return $1
}

# nvm stuff
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PATH stuff
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/go/bin:$HOME/apps/blender:$PATH
export PATH=/home/slaufer/.opencode/bin:$PATH
export PATH="/home/slaufer/.npm-global/bin:$PATH"

cache_in_tmp.sh > /dev/null


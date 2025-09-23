# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export LESS=-RFXS
export PAGER=less

eval "$(dircolors -b)"

shopt -s histappend
export HISTSIZE=
export HISTCONTROL=ignoreboth
export HISTFILESIZE=
export HISTFILE=$HOME/.bash_history

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/go/bin:$PATH
source ~/.bashrc.private
source ~/.bashrc.prompt

alias vim='nvim'
alias gl='git log --graph --pretty="%Cgreen%h %Cblue%cr %Cred%an: %Creset%s"'
alias vea='. venv/bin/activate'
bad() {
  return $1
}

if command -v xsel > /dev/null; then
  alias cb="xsel -ib"
elif command -v xclip > /dev/null; then
  alias cb="xclip -i -selection clipboard"
fi

alias chatgpt='llmcli -p openai -o model=chatgpt-4o-latest'
alias mistral-nemo='llmcli -p ollama -o model=mistral-nemo2'
alias gemma='llmcli -p ollama -o model=gemma3:27b'
alias deepseek='llmcli -p ollama -o model=deepseek-r1:32b'
alias hermes='llmcli -p ollama -o model=hermes3:70b'
alias catherine='llmcli -p ollama -o model=hermes3:70b -c "@~/repos/chatgpt-cli/testdata/catherine.json"'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

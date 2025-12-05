case $- in
    *i*) ;;
      *) return;;
esac

shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
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
alias catherine='llmcli -p ollama -o model=hf.co/mradermacher/calme-3.2-instruct-78b-GGUF:Q4_K_S  -c "@~/repos/chatgpt-cli/testdata/catherine.json"'
alias claude='ANTHROPIC_API_KEY= claude'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias startx='exec `which startx`'

cache_in_tmp.sh > /dev/null


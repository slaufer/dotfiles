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

# 256-color prompt for xterm-like terminals
_VEXING_PROMPT() {
	# grab exit code while we can
	local exit=$?

	# Prompt colors
	# These color codes have to be properly enclosed to prevent wrapping issues
	local COLORS=(
		'\[\e[0m\]'        # 0: reset
		'\[\e[38;5;25m\]'  # 1: Brackets, dark blue
		'\[\e[38;5;35m\]'  # 2: Git unclean branch/staged changes, sea green
		'\[\e[38;5;39m\]'  # 3: Clock and user@host foreground, dark cyan
		'\[\e[38;5;44m\]'  # 4: Directory foreground, bright cyan
		'\[\e[38;5;45m\]'  # 5: Prompt ($/#), sky blue
		'\[\e[38;5;69m\]'  # 6: Clock, directory and user@host background, denim blue
		'\[\e[38;5;160m\]' # 7: Git unclean branch/unstaged changes, red
		'\[\e[38;5;172m\]' # 8: Git unstaged, yellow
		'\[\e[38;5;252m\]' # 9: Git clean branch and command count, light gray
	)

	# TODO: make this dynamic?
	local DIR_WIDTH=60

	# start with a reset
	local prompt="\033]0;$USER@${HOSTNAME} $(pwd)\007"${COLORS[0]}
	
	# status line clock
	local time=($(date '+%l %M%P'))
	prompt+="${COLORS[1]}[${COLORS[3]}${time[0]}${COLORS[6]}:${COLORS[3]}${time[1]}${COLORS[1]}]"

	# status line working directory
	local dir=$(dirs +0)
	(( ${#dir} > DIR_WIDTH )) && dir=...${dir: $((3 - DIR_WIDTH))}
	dir=${dir//\//${COLORS[6]}/${COLORS[4]}}
	prompt+=" ${COLORS[1]}[${COLORS[4]}${dir}${COLORS[1]}]"

	# git status
	# fun fact: "local" has an exit code
	local git_status git_exit=1

	if [[ -z $_VEXING_NOGIT ]]; then
		# either a status (possibly empty) or the return code
		git_status=$(git status -s 2> /dev/null)
		git_exit=$?
	fi

	if (( git_exit == 0 )); then
		# figure out status counts
		local unstaged=$(grep -E '^.[MADRC?]' -c <<< "$git_status")
		local staged=$(grep '^[MADRC]' -c <<< "$git_status")

		# figure out how to color the branch name
		local branch_color=${COLORS[9]}
		(( staged )) && branch_color=${COLORS[2]} 
		(( unstaged )) && branch_color=${COLORS[7]}
		prompt+=" ${COLORS[1]}[${branch_color}$(git rev-parse --abbrev-ref HEAD)${_VEXING_colors[0]}"

		(( unstaged )) && prompt+="${COLORS[7]} ${unstaged}"
		(( staged )) && prompt+="${COLORS[2]} ${staged}"

		prompt+="${COLORS[1]}]"
	fi

	# exit code (if non-zero)
	(( exit )) && prompt+=" ${COLORS[1]}[${COLORS[7]}${exit}${COLORS[1]}]"

	# command count
	prompt+="\n${COLORS[1]}[${COLORS[9]}#\#${_VEXING_colors[0]}${COLORS[1]}] " # command number

	# user, host and prompt
	prompt+="${COLORS[3]}\u${COLORS[6]}@${COLORS[3]}\h ${COLORS[1]}${COLORS[5]}${VIRTUAL_ENV_PROMPT}\$ ${COLORS[0]}"

	# interpret color codes and set the prompt	
	PS1=$(echo -e $prompt)
}

# _VEXING_PROMPT has to go first so it can capture $?
PROMPT_COMMAND="_VEXING_PROMPT; history -a; history -n"
trap '[[ "$BASH_COMMAND" == "_VEXING_PROMPT" ]] || echo -ne "\033]0;$BASH_COMMAND $USER@${HOSTNAME} $(pwd)\007"' DEBUG

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

alias vim='nvim'
alias gl='git log --graph --pretty="%Cgreen%h %Cblue%cr %Cred%an: %Creset%s"'
alias vea='. venv/bin/activate'

if command -v xsel > /dev/null; then
  alias cb="xsel -ib"
elif command -v xclip > /dev/null; then
  alias cb="xclip -i -selection clipboard"
fi

alias chatgpt='llmcli -p openai -o model=chatgpt-4o-latest'
alias claude='llmcli -p anthropic -o model=claude-3-7-sonnet-latest'
alias mistral-nemo='llmcli -p ollama -o model=mistral-nemo2'
alias gemma='llmcli -p ollama -o model=gemma3:27b'
alias deepseek='llmcli -p ollama -o model=deepseek-r1:32b'
alias hermes='llmcli -p ollama -o model=hermes3:70b'
alias catherine='llmcli -p ollama -o model=hermes3:70b -c "@~/repos/chatgpt-cli/testdata/catherine.json"'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

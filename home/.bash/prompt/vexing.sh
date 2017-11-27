#!/bin/bash
# VEXING requires 256 color support
if (( $(tput colors 2> /dev/null || echo 0) < 256 )); then
	echo VEXING requires 256 color support
	return
fi

# 256-color prompt for xterm-like terminals
function _VEXING_PROMPT {
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
	local prompt=${COLORS[1]}
	
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
	prompt+="${COLORS[3]}\u${COLORS[6]}@${COLORS[3]}\h ${COLORS[1]}${COLORS[5]}\$ ${COLORS[0]}"

	# interpret color codes and set the prompt	
	PS1=$(echo -e $prompt)
}

PROMPT_COMMAND=_VEXING_PROMPT


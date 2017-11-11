#!/bin/bash
# VEXING requires 256 color support
if (( $(tput colors) < 256 )); then
	echo VEXING requires 256 color support
	return
fi

#################
# CONFIGURATION #
#################

# TODO: make this dynamic?
_VEXING_DIR_WIDTH=70

# Prompt colors
# These color codes have to be properly enclosed to prevent wrapping issues
_VEXING_COLORS=(
	'\[\e[0m\]'                  # 0: reset
	"\[\e[38;5;25m\e[48;5;0m\]"  # 1: Brackets, dark blue
	"\[\e[38;5;35m\e[48;5;0m\]"  # 2: Git clean/staged, sea green
	"\[\e[38;5;39m\e[48;5;0m\]"  # 3: Clock and user@host foreground, dark cyan
	"\[\e[38;5;44m\e[48;5;0m\]"  # 4: Directory foreground, bright cyan
	"\[\e[38;5;45m\e[48;5;0m\]"  # 5: Prompt ($/#), sky blue
	"\[\e[38;5;69m\e[48;5;0m\]"  # 6: Clock, directory and user@host background, denim blue
	"\[\e[38;5;160m\e[48;5;0m\]" # 7: Git untracked, red
	"\[\e[38;5;172m\e[48;5;0m\]" # 8: Git unstaged, burnt orange
	"\[\e[38;5;252m\e[48;5;0m\]" # 9: Command count, light gray
)

####################
# Helper Functions #
####################

# Colorizes a path, and replaces home with ~
function _VEXING_color_dir {
	# get directory with homedir substitution
	local dir=$(dirs +0)

	# trim directory
	(( ${#dir} > $_VEXING_DIR_WIDTH )) && dir=${dir: -$_VEXING_DIR_WIDTH}

	# color directory
	dir=${dir//\//${_VEXING_COLORS[6]}/${_VEXING_COLORS[4]}}
	echo -n $dir
}

####################
# Prompt Functions #
####################

# 256-color prompt for xterm-like terminals
function _VEXING_prompt_8bit {
	local EXIT=$?
	local PROMPT
	
	# status line clock
	local TIME=($(date '+%l %M%P'))
	PROMPT+="${_VEXING_COLORS[1]}[${_VEXING_COLORS[3]}${TIME[0]}${_VEXING_COLORS[6]}:${_VEXING_COLORS[3]}${TIME[1]}${_VEXING_COLORS[1]}]"
	# status line working directory
	PROMPT+=" ${_VEXING_COLORS[1]}[${_VEXING_COLORS[4]}$(_VEXING_color_dir "$PWD")${_VEXING_COLORS[1]}]"


	# git status
	local GIT_STATUS GIT_EXIT=1 # because "local" has a return code

	if [[ -z $_VEXING_NOGIT ]]; then
		# either a status (possibly empty) or the return code
		GIT_STATUS=$(git status -s 2> /dev/null)
		GIT_EXIT=$?
	fi

	if (( $GIT_EXIT == 0 )); then
		# figure out status counts
		local UNTRACKED=$(grep '^[ ?][ ?]' -c <<< "$GIT_STATUS")
		local UNSTAGED=$(grep '^ [MADRC]' -c <<< "$GIT_STATUS")
		local STAGED=$(grep '^[MADRC]' -c <<< "$GIT_STATUS")

		# figure out how to color the branch name
		local BRANCH_COLOR=${_VEXING_COLORS[2]}
		(( $UNSTAGED > 0 )) || (( $UNTRACKED > 0 )) && BRANCH_COLOR=${_VEXING_COLORS[7]}
		(( $STAGED > 0 ))  && BRANCH_COLOR=${_VEXING_COLORS[8]} 
		PROMPT+=" ${_VEXING_COLORS[1]}[${BRANCH_COLOR}$(git rev-parse --abbrev-ref HEAD)${_VEXING_colors[0]}"

		[[ $UNTRACKED -gt 0 ]] && PROMPT+="${_VEXING_COLORS[7]} ${UNTRACKED}" 
		[[ $UNSTAGED -gt 0 ]] && PROMPT+="${_VEXING_COLORS[8]} ${UNSTAGED}"
		[[ $STAGED -gt 0 ]] && PROMPT+="${_VEXING_COLORS[2]} ${STAGED}"

		PROMPT+="${_VEXING_COLORS[1]}]"
	fi

	# exit code (if non-zero)
	if (( $EXIT != 0 )); then
		PROMPT+=" ${_VEXING_COLORS[1]}[${_VEXING_COLORS[7]}${EXIT}${_VEXING_COLORS[1]}]" # exit code
	fi

	# command count
	PROMPT+="\n${_VEXING_COLORS[1]}[${_VEXING_COLORS[9]}#\#${_VEXING_colors[0]}${_VEXING_COLORS[1]}] " # command number

	# user, host and prompt
	PROMPT+="${_VEXING_COLORS[3]}\u${_VEXING_COLORS[6]}@${_VEXING_COLORS[3]}\h ${_VEXING_COLORS[1]}${_VEXING_COLORS[5]}\$ ${_VEXING_COLORS[0]}"

	# interpret color codes and set the prompt	
	PS1=$(echo -e $PROMPT)
}

PROMPT_COMMAND=_VEXING_prompt_8bit


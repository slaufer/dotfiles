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
	'\[\e[0m\]'        # 0: reset
	"\[\e[38;5;25m\]"  # 1: Brackets, dark blue
	"\[\e[38;5;35m\]"  # 2: Git unclean branch/staged changes, sea green
	"\[\e[38;5;39m\]"  # 3: Clock and user@host foreground, dark cyan
	"\[\e[38;5;44m\]"  # 4: Directory foreground, bright cyan
	"\[\e[38;5;45m\]"  # 5: Prompt ($/#), sky blue
	"\[\e[38;5;69m\]"  # 6: Clock, directory and user@host background, denim blue
	"\[\e[38;5;160m\]" # 7: Git unclean branch/unstaged changes, red
	"\[\e[38;5;172m\]" # 8: Git unstaged, yellow
	"\[\e[38;5;252m\]" # 9: Git clean branch and command count, light gray
)

####################
# Helper Functions #
####################

# Colorizes a path, and replaces home with ~
function _VEXING_color_dir {
	# get directory with homedir substitution
	local dir=$(dirs +0)

	# trim directory
	(( ${#dir} > _VEXING_DIR_WIDTH )) && dir=${dir: -$_VEXING_DIR_WIDTH}

	# color directory
	dir=${dir//\//${_VEXING_COLORS[6]}/${_VEXING_COLORS[4]}}
	echo -n $dir
}

####################
# Prompt Functions #
####################

# 256-color prompt for xterm-like terminals
function _VEXING_prompt_8bit {
	local exit=$?

	# start with a reset
	local prompt=${_VEXING_COLORS[1]}
	
	# status line clock
	local TIME=($(date '+%l %M%P'))
	prompt+="${_VEXING_COLORS[1]}[${_VEXING_COLORS[3]}${TIME[0]}${_VEXING_COLORS[6]}:${_VEXING_COLORS[3]}${TIME[1]}${_VEXING_COLORS[1]}]"
	# status line working directory
	prompt+=" ${_VEXING_COLORS[1]}[${_VEXING_COLORS[4]}$(_VEXING_color_dir "$PWD")${_VEXING_COLORS[1]}]"


	# git status
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
		local branch_color=${_VEXING_COLORS[9]}
		(( staged > 0 )) && branch_color=${_VEXING_COLORS[2]} 
		(( unstaged > 0 )) && branch_color=${_VEXING_COLORS[7]}
		prompt+=" ${_VEXING_COLORS[1]}[${branch_color}$(git rev-parse --abbrev-ref HEAD)${_VEXING_colors[0]}"

		(( unstaged > 0 )) && prompt+="${_VEXING_COLORS[7]} ${unstaged}"
		(( staged > 0 )) && prompt+="${_VEXING_COLORS[2]} ${staged}"

		prompt+="${_VEXING_COLORS[1]}]"
	fi

	# exit code (if non-zero)
	if (( exit != 0 )); then
		prompt+=" ${_VEXING_COLORS[1]}[${_VEXING_COLORS[7]}${exit}${_VEXING_COLORS[1]}]"
	fi

	# command count
	prompt+="\n${_VEXING_COLORS[1]}[${_VEXING_COLORS[9]}#\#${_VEXING_colors[0]}${_VEXING_COLORS[1]}] " # command number

	# user, host and prompt
	prompt+="${_VEXING_COLORS[3]}\u${_VEXING_COLORS[6]}@${_VEXING_COLORS[3]}\h ${_VEXING_COLORS[1]}${_VEXING_COLORS[5]}\$ ${_VEXING_COLORS[0]}"

	# interpret color codes and set the prompt	
	PS1=$(echo -e $prompt)
}

PROMPT_COMMAND=_VEXING_prompt_8bit


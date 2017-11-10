#!/bin/bash

#################
# CONFIGURATION #
#################

_VEXING_DIR_WIDTH=70

####################
# Helper Functions #
####################

# This function sets ANSI colors.
# Usage:
# - col r
#     reset colors
# - col 3 <0-7> <0-7>
#     set 3-bit foreground and background color; value range is 0-7
# - col 8 <fg> <bg>
#     set 8-bit foreground and background color; value range is 0-255
# - col 24 <fg red> <fg green> <fg blue> <bg red> <bg green> <bg blue>
#     set 24-bit background color; value range is 0-255

_VEXING_COLORS=(
	"\[\e[0m\]"                  # 0: reset
	"\[\e[38;5;25m\e[48;5;0m\]"  # 1: dark blue
	"\[\e[38;5;35m\e[48;5;0m\]"  # 2: sea green
	"\[\e[38;5;39m\e[48;5;0m\]"  # 3: bright green
	"\[\e[38;5;44m\e[48;5;0m\]"  # 4: bright cyan
	"\[\e[38;5;45m\e[48;5;0m\]"  # 5: sky blue
	"\[\e[38;5;69m\e[48;5;0m\]"  # 6: light purple-blue
	"\[\e[38;5;160m\e[48;5;0m\]" # 7: dark red
	"\[\e[38;5;172m\e[48;5;0m\]" # 8: burnt orange
	"\[\e[38;5;252m\e[48;5;0m\]" # 9: light gray
)

function _VEXING_color_dir {
	# convert $HOME to ~
	local TILDE="~"
	local DIR="${1/$HOME/$TILDE}"
	DIR="$(echo "$DIR" | tail -c "$_VEXING_DIR_WIDTH")"
	DIR="${DIR//\//${_VEXING_COLORS[6]}/${_VEXING_COLORS[4]}}"
	echo "$DIR"
}

####################
# Prompt Functions #
####################

# 256-color prompt for xterm-like terminals
function _VEXING_prompt_8bit {
	echo $?
	local PROMPT=""
	
	# status line clock
	PROMPT+="${_VEXING_COLORS[1]}[${_VEXING_COLORS[3]}$(date "+%l")${_VEXING_COLORS[6]}:${_VEXING_COLORS[3]}$(date "+%M%P")${_VEXING_COLORS[1]}]"
	# status line working directory
	PROMPT+=" ${_VEXING_COLORS[1]}[${_VEXING_COLORS[4]}$(_VEXING_color_dir "$PWD")${_VEXING_COLORS[1]}]"


	# git status
	if [[ -z "$_VEXING_NOGIT" ]]; then
		# either a status (possibly empty) or the return code
		local GITSTATUS="$(git status -s 2> /dev/null || echo $?)"
	else
		# just set it to the failure return code
		local GITSTATUS=128
	fi

	if [[ "$GITSTATUS" != "128" ]]; then
		local UNTRACKED="$(grep "^[ ?][ ?]" -c <<< "$GITSTATUS")"
		local UNSTAGED="$(grep "^ [MADRC]" -c <<< "$GITSTATUS")"
		local STAGED="$(grep "^[MADRC]" -c <<< "$GITSTATUS")"


		local GIT_COLOR="${_VEXING_COLORS[2]}"
		(( $UNSTAGED > 0 )) || (( $UNTRACKED > 0 )) && local GIT_COLOR="${_VEXING_COLORS[7]}" 
		(( $STAGED > 0 ))  && local GIT_COLOR="${_VEXING_COLORS[8]}" 
		PROMPT+=" ${_VEXING_COLORS[1]}[${GIT_COLOR}$(git rev-parse --abbrev-ref HEAD)${_VEXING_colors[0]}"

		[ "$UNTRACKED" -gt "0" ] &&	PROMPT+="${_VEXING_COLORS[7]} ${UNTRACKED}" 
		[ "$UNSTAGED" -gt "0" ] && PROMPT+="${_VEXING_COLORS[8]} ${UNSTAGED}"
		[ "$STAGED" -gt "0" ] && PROMPT+="${_VEXING_COLORS[2]} ${STAGED}"

		PROMPT+="${_VEXING_COLORS[1]}]"
	fi

	# exit code (if non-zero)
	#if (( $EXIT != 0 )); then
	#	PROMPT+="${_VEXING_COLORS[1]}[${_VEXING_COLORS[7]}${EXIT}${_VEXING_COLORS[1]}]" # exit code
	#fi

	# command count
	PROMPT+="\n${_VEXING_COLORS[1]}[${_VEXING_COLORS[9]}#\#${_VEXING_colors[0]}${_VEXING_COLORS[1]}] " # command number

	# user, host and prompt
	PROMPT+="${_VEXING_COLORS[1]}${_VEXING_COLORS[3]}\u${_VEXING_COLORS[6]}@${_VEXING_COLORS[3]}\h${_VEXING_COLORS[1]} ${_VEXING_COLORS[5]}\$ ${_VEXING_COLORS[0]}"
	
	PS1="$(echo -e "$PROMPT")"
}

# only activate the fancy prompt if this is a 256-color terminal
_VEXING_COLOR_COUNT="$(tput colors)"
if [ "$_VEXING_COLOR_COUNT" -ge "256" ]; then
	export PROMPT_COMMAND="_VEXING_prompt_8bit"
else
	echo "VEXING: 256 color mode unavailable, using mono fallback prompt"
	export PS1='($?) \u@\h \w \$ '
fi

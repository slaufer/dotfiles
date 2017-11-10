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

function _VEXING_col {
	[ "$1" == "r" ] && { echo "\[\e[0m\]"; return; }
	[ "$1" == "3" ] && { echo "\[\e[3${2};4${3}m\]"; return; }
	[ "$1" == "8" ] && { echo "\[\e[38;5;${2}m\e[48;5;${3}m\]"; return; }
	[ "$1" == "24" ] && { echo "\[\e[38;2;${2};${3};${4}m\e[48;2;${5};${6}${7}m\]"; return; }
}

function _VEXING_color_dir {
	# convert $HOME to ~
	local TILDE="~"
	local DIR="${1/$HOME/$TILDE}"
	DIR="$(echo "$DIR" | tail -c "$_VEXING_DIR_WIDTH")"
	DIR="${DIR//\//$(_VEXING_col 8 69 0)/$(_VEXING_col 8 44 0)}"
	echo "$DIR"
}

####################
# Prompt Functions #
####################

# 256-color prompt for xterm-like terminals
function _VEXING_prompt_8bit {
	local EXIT="$?"
	local PROMPT=""
	local SPACER="$(_VEXING_col r) "
	
	# status line
	PROMPT="${PROMPT}$(_VEXING_col 8 25 0)[$(_VEXING_col 8 39 0)$(date "+%l")$(_VEXING_col 8 69 0):$(_VEXING_col 8 39 0)$(date "+%M%P")$(_VEXING_col 8 25 0)]" # clock
	PROMPT="${PROMPT} $(_VEXING_col 8 25 0)[$(_VEXING_col 8 44 0)$(_VEXING_color_dir "$PWD")$(_VEXING_col 8 25 0)]" # working directory


	# git status
	if [[ -z "$_VEXING_NOGIT" ]]; then
		local GITSTATUS="$(git status -s 2> /dev/null)"

		if [[ ! -z "$GITSTATUS" ]]; then
			local GITSTATUS="$(git status -s 2> /dev/null)"
			local UNTRACKED="$(grep "^[ ?][ ?]" <<< "$GITSTATUS" | wc -l)"
			local UNSTAGED="$(grep "^ [MADRC]" <<< "$GITSTATUS" | wc -l)"
			local STAGED="$(grep "^[MADRC]" <<< "$GITSTATUS" | wc -l)"


			local GIT_COLOR="$(_VEXING_col 8 35 0)"
			[ "$UNSTAGED" -gt "0" ] || [ "$UNTRACKED" -gt "0" ] && local GIT_COLOR="$(_VEXING_col 8 160 0)" 
			[ "$STAGED" -gt "0" ] && local GIT_COLOR="$(_VEXING_col 8 172 0)" 
			PROMPT="${PROMPT} $(_VEXING_col 8 25 0)[${GIT_COLOR}$(git rev-parse --abbrev-ref HEAD)$(_VEXING_col r)"

			[ "$UNTRACKED" -gt "0" ] &&	PROMPT="${PROMPT}$(_VEXING_col 8 160 0) ${UNTRACKED}$(_VEXING_col r)" 
			[ "$UNSTAGED" -gt "0" ] && PROMPT="${PROMPT}$(_VEXING_col 8 172 0) ${UNSTAGED}$(_VEXING_col r)"
			[ "$STAGED" -gt "0" ] && PROMPT="${PROMPT}$(_VEXING_col 8 35 0) ${STAGED}$(_VEXING_col r)"

			PROMPT="${PROMPT}$(_VEXING_col 8 25 0)]"
		fi
	fi

	# exit code (if non-zero)
	if [ "$EXIT" -ne "0" ]; then
		PROMPT="${PROMPT} $(_VEXING_col 8 25 0)[$(_VEXING_col 8 160 0)${EXIT}$(_VEXING_col 8 25 0)]" # exit code
	fi

	PROMPT="${PROMPT}\n$(_VEXING_col 8 25 0)[$(_VEXING_col 8 252 0)#\#$(_VEXING_col r)$(_VEXING_col 8 25 0)] " # command number


	# prompt line
	PROMPT="${PROMPT}$(_VEXING_col 8 25 0)$(_VEXING_col 8 39 0)\u$(_VEXING_col 8 69 0)@$(_VEXING_col 8 39 0)\h$(_VEXING_col 8 25 0) $(_VEXING_col 8 45 0)\$ $(_VEXING_col r)"
	
	PS1="$(echo -e $PROMPT)"
}

# super basic prompt for older terminals
function _VEXING_prompt_mono {
	PS1='($?) \u@\h \w \$ '
}

# only activate the fancy prompt if this is a 256-color terminal
_VEXING_COLOR_COUNT="$(tput colors)"
if [ "$_VEXING_COLOR_COUNT" -ge "256" ]; then
	export PROMPT_COMMAND=_VEXING_prompt_8bit
else
	echo "VEXING: 256 color mode unavailable, using mono fallback prompt"
	export PROMPT_COMMAND=_VEXING_prompt_mono
fi

#!/bin/bash

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

function col {
	[ "$1" == "r" ] && { echo "\[\e[0m\]"; return; }
	[ "$1" == "3" ] && { echo "\[\e[3${2};4${3}m\]"; return; }
	[ "$1" == "8" ] && { echo "\[\e[38;5;${2}m\e[48;5;${3}m\]"; return; }
	[ "$1" == "24" ] && { echo "\[\e[38;2;${2};${3};${4}m\e[48;2;${5};${6}${7}m\]"; return; }
}

####################
# Prompt Functions #
####################

# 256-color prompt for xterm-like terminals
function prompt_8bit {
	local EXIT="$?"
	local PROMPT=""
	local SPACER="$(col r) "
	
	# status line
	PROMPT="${PROMPT}$(col 8 253 238) $(date "+%I:%M:%S %P") $(col r)" # clock
	PROMPT="${PROMPT}${SPACER}$(col 8 255 20) $(echo $PWD | tail -c75) $(col r)" # working directory
	PROMPT="${PROMPT}${SPACER}$(col 8 235 252) #\# $(col r)" # command number

	# exit code (if non-zero)
	if [ "$EXIT" -ne "0" ]; then
		PROMPT="${PROMPT}${SPACER}$(col 8 255 160) ${EXIT} $(col r)" # exit code
	fi

	# git status
	if git status > /dev/null 2> /dev/null; then
		local GITSTATUS="$(git status -s 2> /dev/null)"
		local UNTRACKED="$(echo "$GITSTATUS" | grep "^[ ?][ ?]" | wc -l)"
		local UNSTAGED="$(echo "$GITSTATUS" | grep "^ [MADRC]" | wc -l)"
		local STAGED="$(echo "$GITSTATUS" | grep "^[MADRC]" | wc -l)"


		local GIT_COLOR="$(col 8 255 35)"
		[ "$UNSTAGED" -gt "0" ] || [ "$UNTRACKED" -gt "0" ] && local GIT_COLOR="$(col 8 255 160)" 
		[ "$STAGED" -gt "0" ] && local GIT_COLOR="$(col 8 255 172)" 
		PROMPT="${PROMPT}\n${GIT_COLOR} $(git rev-parse --abbrev-ref HEAD) $(col r)"

		[ "$UNTRACKED" -gt "0" ] &&	PROMPT="${PROMPT}${SPACER}$(col 8 255 160) ${UNTRACKED} untracked $(col r)" 
		[ "$UNSTAGED" -gt "0" ] && PROMPT="${PROMPT}${SPACER}$(col 8 255 172) ${UNSTAGED} unstaged $(col r)"
		[ "$STAGED" -gt "0" ] && PROMPT="${PROMPT}${SPACER}$(col 8 255 35) ${STAGED} staged $(col r)"

	fi

	# prompt line
	PROMPT="${PROMPT}\n"
	PROMPT="${PROMPT}$(col 8 51 0)\u$(col 8 27 0)@$(col 8 51 0)\h$(col r) $(col 8 27 0)\$ $(col r)"
	
	PS1="$(echo -e $PROMPT)"
}

# 8-color prompt for standard color terminals
function prompt_3bit {
	prompt_mono
}

# super basic prompt for older terminals
function prompt_mono {
	PS1='($?) \u@\h \w \$ '
}

# only activate the fancy prompt if this is a 256-color terminal
COLORS="$(tput colors)"
if [ "$COLORS" -ge "256" ]; then
	export PROMPT_COMMAND=prompt_8bit
elif [ "$COLORS" -ge "8" ]; then
	export PROMPT_COMMAND=prompt_3bit
else
	export PROMPT_COMMAND=prompt_mono
fi

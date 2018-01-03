#!/bin/bash
# assorted aliases and scripts that aren't big enough for their own file

##
# git aliases
alias gst='git status'
alias gfe='git fetch && git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gl='git log --graph --all --pretty="%Cgreen%h %Cred%an: %Creset%s"'
alias gb='git branch | cut -c3- | xargs dialog --no-items --menu "MENU!" $(($(tput lines) *3 / 4)) $(($(tput cols) * 3 / 4)) $(tput lines) 3>&2 2>&1 1>&3 | xargs git checkout'
alias gcom='git log --date=iso --all --pretty=$'\''%h\2%cd %aN %s\2'\'' | tr -d '\''\n'\'' | xargs -d $'\''\2'\'' dialog --menu "MENU!" $(tput lines) $(tput cols) $(tput lines) 3>&2 2>&1 1>&3 | xargs git checkout'

##
# hexdump aliases

# wide hex/asc
alias hda='hexdump -e '\''"| %4_ax | " 16/1 "%02x " " |" '\'' -e '\''" %5_ad | " 16 "%1_p" " |\n"'\'

# narrow octal/hex/asc
alias hdo='hexdump -e '\''"| %8_ao | " 8/1 "%03o " " |"'\'' -e '\''" %4_ax | " 8/1 "%02x " " |" '\'' -e '\''" %5_ad | " 8 "%1_p" " |\n"'\'

##
# other aliases
alias noeol="perl -pi -e 'chomp if eof'"
alias mkdir='mkdir -p'
alias grep='grep --color=auto'
alias ls='ls -hF --color=auto'
alias psf="ps fxU $USER"

##
# ack_all
# searches a list of :-delimited paths using ack
# ack_all [ack args...] <path list>
function ack_all {
	# copy args to a usable variable name. parens are necessary to remind bash this is an array
	local argv=("${@}")
	local argc="${#argv[@]}"
	local argl="$((argc - 1))"

	local -a ack_args=("${argv[@]:0:$argl}")

	local -a paths
	IFS=':' read -r -a paths <<< "${argv[$argl]}"

	local p
	for p in "${paths[@]}"; do
		ack "${ack_args[@]}" "$p"
	done
}

##
# find_all
# searches a list of :-delimited paths using find
# find_all <path list> [find args...]
function find_all {
	# copy args to a usable variable name. parens are necessary to remind bash this is an array
	local argv=("${@}")
	local argc="${#argv[@]}"

	local -a find_args=("${argv[@]:1}")

	local -a paths
	IFS=':' read -r -a paths <<< "${argv[0]}"

	local p
	for p in "${paths[@]}"; do
		find "$p" "${find_args[@]}"
	done
}


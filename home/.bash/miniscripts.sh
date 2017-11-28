#!/bin/bash
# assorted aliases and scripts that aren't big enough for their own file

# git aliases
alias gst='git status'
alias gfe='git fetch && git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gl='git log --graph --all --pretty="%Cgreen%h %Cred%an: %Creset%s"'

# other aliases
alias noeol="perl -pi -e 'chomp if eof'"
alias mkdir='mkdir -p'
alias grep='grep --color=auto'
alias ls='ls -hF --color=auto'
alias procs="ps fxU $USER"

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

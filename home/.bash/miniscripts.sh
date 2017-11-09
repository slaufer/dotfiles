#!/bin/bash
# assorted scripts that aren't big enough for their own file

##
# ack_all
# searches a list of :-delimited paths using ack
# ack_all [ack args...] <path list>
function ack_all {
	# copy args to a usable variable name. parens are necessary to remind bash this is an array
	local argv=("${@}")
	local argc="${#argv[@]}"
	local argl="$(($argc - 1))"

	local -a ack_args=("${argv[@]:0:$argl}")

	local -a paths
	IFS=':' read -r -a paths <<< "${argv[$(($argc - 1))]}"

	local p
	for p in "${paths[@]}"; do
		ack "${ack_args[@]}" "$p"
	done
}

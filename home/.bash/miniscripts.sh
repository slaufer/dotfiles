
#!/bin/bash
# assorted aliases and scripts that aren't big enough for their own file

##
# git aliases
alias gst='git status'
alias gfe='git fetch && git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gl='git log --graph --pretty="%Cgreen%h %Cblue%cr %Cred%an: %Creset%s"'
alias gla='git log --graph --all --pretty="%Cgreen%h %Cred%an: %Creset%s"'

##
# other aliases
alias decolor="sed -e 's/'$'\e''\[[0-9;]*m//g'"
alias noeol="perl -pi -e 'chomp if eof'"
alias mkdir='mkdir -p'
alias grep='grep --color=auto'
alias ls='ls -hF --color=auto'
alias dotfiles='homeshick cd dotfiles'
alias psf="ps fxU $USER"
which nvim > /dev/null && alias vim='nvim'
which neovim > /dev/null && alias vim='neovim'

##
# ssh aliases
alias vam01="ssh vam01.slaufer"
alias contango-ci="ssh contango01.cap.ci"
alias contango-qa="ssh contango01.cap.qa"

##
# gcd
# cd within git repo
function gcd {
	cd "$(git rev-parse --show-toplevel)$1"
}

##
# imgur_rip
# rips an imgur album, outputs images as <album_hash>_<image_hash>.<ext> in the current directory
# imgur_rip <album_hash>
function imgur_rip {
	local album=$1
	curl --progress-bar -s "https://imgur.com/ajaxalbums/getimages/${album}/hit.json" |
		jq -r '.data.images[] | ["url=\"https://i.imgur.com/",.hash,.ext,"\"\noutput=\"'$album'_",.hash,.ext,"\""] | join("")' | curl --progress-bar -K -
}


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


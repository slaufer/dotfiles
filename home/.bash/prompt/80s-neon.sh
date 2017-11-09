# color palette
C0='\[\e[38;5;206m\]'
C1='\[\e[38;5;51m\]'
C2='\[\e[38;5;141m\]'
COK=$C0
#COK='\[\e[38;5;10m\]'
CFAIL='\[\e[38;5;196m\]'

# separator
SEP=' '$C0'\\'$C2'\\'$C1'\\ '

function prompt_path_color {
	local OUT=$1
	local OUT=${OUT//~/$C0~$C1}
	local OUT=${OUT//\//$C2\/$C1}
	echo $C1$OUT
}

function prompt_path {
	local SPWD=${PWD/$HOME/\~}

	if [ ${#SPWD} -le $1 ]; then
		echo `prompt_path_color "$SPWD"`
	else
		echo $C2'...'`prompt_path_color "${SPWD: -$(($1 - 3))}"`
	fi
}

function prompt_color {
	# first get some information
	local EXIT="$?"
	local COLS=`tput cols`
	
	# reset prompt
	PS1=""

	# title
	PS1+='\[\033]0;\u@\h:\w\a\]'
	
	# clock
	PS1+=`date +$C1'%I'$C2':'$C1'%M'$C2':'$C1'%S '$C2'%P'`
	
	# directory
	PS1+=$SEP
	local DWIDTH=16 # if you customize the prompt, you'll have to adjust this
	PS1+=`prompt_path $(($COLS - $DWIDTH))`
	
	# user@host
	PS1+='\n'$C1'\u'$C2'@'$C1'\h'
	
	# return code
	PS1+=$SEP
	if [ $EXIT -eq 0 ]; then
		PS1+=$C2'('$COK$EXIT$C2') '
	else
		PS1+=$C2'('$CFAIL$EXIT$C2') '
	fi
	
	# prompt
	PS1+=$C1'\$\[\e[m\] '
}

# super basic prompt for older terminals
function prompt_bw {
	local EXIT=$?

	# double evals mean we need to write like a billion slashes here
	PS1=`date +"%I:%M:%S %P"`' \\\\\\\\\\\\ \w\n\u@\h \\\\\\\\\\\\ ('$EXIT') \$ '
}

# only activate the fancy prompt if this is a 256-color terminal
if [ `tput colors` = "256" ]; then
	export PROMPT_COMMAND=prompt_color
else
	export PROMPT_COMMAND=prompt_bw
fi

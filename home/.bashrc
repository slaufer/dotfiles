# .bashrc

# if this shell isn't interactive, bail out
[[ $- != *i* ]] && return

# Source global definitions
[[ /etc/bashrc ]] && source /etc/bashrc

# set up path
export PATH=$PATH:$HOME/bin:$HOME/.bin

# infinite history
export HISTSIZE=""

# dircolors
which dircolors > /dev/null && eval "$(dircolors -b)"

# aliases
alias gup='git fetch && git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gl='git log --graph --all --pretty="%Cgreen%h %Cred%an: %Creset%s"'
alias noeol="perl -pi -e 'chomp if eof'"
alias mkdir="mkdir -p"
alias grep="grep --color=auto"
alias 

# Java development env vars


# VAM-specific env vars
if echo $HOSTNAME | grep '^vxm[0-9]\{0,\}\.' > /dev/null; then
	echo "Loading VAM configs"
	. $HOME/.vamrc
	PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
	PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
	PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
	PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
	PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
fi

source ~/.bash/vexing.sh
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

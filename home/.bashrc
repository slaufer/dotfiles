# .bashrc

# if this shell isn't interactive, bail out
[[ $- != *i* ]] && return

# Source global definitions
[[ -f "/etc/bashrc" ]] && . "/etc/bashrc"

# set up path
export PATH=$PATH:$HOME/bin

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
alias ls="ls -hF --color=auto"

# VAM-specific env vars
echo "$HOSTNAME" | grep '^vam[0-9]\{0,\}\.' > /dev/null && . "$HOME/.bash/vamhost.bashrc"

# local bashrc (if any)
[[ -e "$HOME/.bash/localrc/${HOSTNAME}.bashrc" ]] && . "$HOME/.bash/localrc/${HOSTNAME}.bashrc"

# homeshick
. "$HOME/.homesick/repos/homeshick/homeshick.sh"

# shell prompt
. ~/.bash/prompt/vexing.sh

return 0

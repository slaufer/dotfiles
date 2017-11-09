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
alias ls="ls -hF --color=auto"

# VAM-specific env vars
echo "$HOSTNAME" | grep '^vxm[0-9]\{0,\}\.' > /dev/null && source "~/.bash/vamhost.bashrc"

# shell prompt
source ~/.bash/vexing.sh

# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# local bashrc (if any)
[[ -f "~/.bash/${HOSTNAME}.bashrc" ]] && source "~/.bash/${HOSTNAME}.bashrc"

return 0

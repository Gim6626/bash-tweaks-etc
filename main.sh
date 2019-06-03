source ~/.bash-tweaks/colors.sh
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PS1="\[$BGreen\][\A]$CR\u@\h\[$BBlue\][\W]$CR\$ "
alias grep='grep --color'
alias less='less -RN'
alias mc='mc --skin=modarin256'
alias mcedit='mcedit --skin=modarin256'
export EDITOR="mcedit --skin=modarin256"
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
export HISTSIZE=10000
export HISTFILESIZE=10000
export PATH=/sbin:$PATH

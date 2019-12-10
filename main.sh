source ~/.bash-tweaks/colors.sh
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PS_DATE_COLOR=$BGreen
export PS_CWD_COLOR=$BBlue
if [ "$USER" != 'root' ]
then
    export PS1="\[$PS_DATE_COLOR\][\A]$CR\u@\h\[$PS_CWD_COLOR\][\W]$CR\$ "
else
    export PS1="\[$PS_DATE_COLOR\][\A]$CR\u@\h\[$PS_CWD_COLOR\][\W]$CR# "
fi
alias grep='grep --color'
alias less='less -RN'
alias mc='mc --skin=modarin256'
alias mcedit='mcedit --skin=modarin256'
alias mcview='mcview --skin=modarin256'
export EDITOR="mcedit --skin=modarin256"
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
export PATH=/sbin:$PATH

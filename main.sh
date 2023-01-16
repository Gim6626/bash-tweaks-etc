#!/bin/bash
# "BASH tweaks etc"
#
# Copyleft 2017-2019
# GPL v3 License or later
# Author: Dmitriy Vinokurov
# Email: gim6626@gmail.com
# Questions and contributions are welcome at https://github.com/Gim6626/bash-tweaks-etc

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
export MC_SKIN='default'
alias mc="mc --skin=$MC_SKIN"
alias mcedit="mcedit --skin=$MC_SKIN"
alias mcview="mcview --skin=$MC_SKIN"
export EDITOR="mcedit --skin=$MC_SKIN"
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
export PATH=/sbin:$PATH
export HISTSIZE=10000
export HISTFILESIZE=10000

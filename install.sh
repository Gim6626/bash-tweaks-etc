#!/bin/bash

set -e
BTWMAIN=main.sh
BTWCOLORS=colors.sh
BTWREPO=bash-tweaks-etc
BTWDIR=.bash-tweaks
NANOCONF=nanorc
NANOCONF_SYSTEM_PATH=~/.nanorc
I=1
STEPS=5

PS_DATE_COLOR_STR=""
PS_CWD_COLOR_STR=""

function ask_color
{
    PURPOSE=$1
    DEFAULT_COLOR_NUM=$2
    DEFAULT_COLOR=$3
    TARGET_VARIABLE_NAME=$4
    echo "  Choose color for $PURPOSE:"
    . ~/$BTWDIR/$BTWCOLORS
    echo -e "  1. Black ${BBlack}${PURPOSE}${Color_Off}"
    echo -e "  2. Red ${BRed}${PURPOSE}${Color_Off}"
    echo -e "  3. Green ${BGreen}${PURPOSE}${Color_Off}"
    echo -e "  4. Yellow ${BYellow}${PURPOSE}${Color_Off}"
    echo -e "  5. Blue ${BBlue}${PURPOSE}${Color_Off}"
    echo -e "  6. Purple ${BPurple}${PURPOSE}${Color_Off}"
    echo -e "  7. Cyan ${BCyan}${PURPOSE}${Color_Off}"
    echo -e "  8. White ${BWhite}${PURPOSE}${Color_Off}"
    read -p "  Enter your choice for $PURPOSE (default ${DEFAULT_COLOR_NUM}-${DEFAULT_COLOR}): " COLOR_NUM
    case "$COLOR_NUM" in
    "1")
        COLOR_STR="\$BBlack"
        ;;
    "2")
        COLOR_STR="\$BRed"
        ;;
    "3")
        COLOR_STR="\$BGreen"
        ;;
    "4")
        COLOR_STR="\$BYellow"
        ;;
    "5")
        COLOR_STR="\$BBlue"
        ;;
    "6")
        COLOR_STR="\$BPurple"
        ;;
    "7")
        COLOR_STR="\$BCyan"
        ;;
    "8")
        COLOR_STR="\$BWhite"
        ;;
    *)
        COLOR_STR="\$B$DEFAULT_COLOR"
        ;;
    esac
    eval "$TARGET_VARIABLE_NAME='$COLOR_STR'"
}

#
# Check
#
# TODO: Unite check ifs to loop
echo "[$I/$STEPS] Checking required files"
if [ -f $BTWMAIN ]
then
    echo "  $BTWMAIN - OK"
else
    echo "  Error: Could not find '$BTWMAIN' file in current directory. '$0' script should be executed from root directory of '$BTWREPO' repo"
    exit 1
fi
if [ -f $BTWCOLORS ]
then
    echo "  $BTWCOLORS - OK"
else
    echo "  Error: Could not find '$BTWCOLORS' file in current directory. '$0' script should be executed from root directory of '$BTWREPO' repo"
    exit 1
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Install
#
echo "[$I/$STEPS] Installing bash tweaks files"
# TODO: Make output more detailed and installation more "clever"
echo "  Creating '$BTWDIR'"
mkdir -p ~/$BTWDIR
echo "  Copying config files to '$BTWDIR'"
echo "    $BTWMAIN"
cp $BTWMAIN ~/$BTWDIR
echo "    $BTWCOLORS"
cp $BTWCOLORS ~/$BTWDIR
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate bash tweaks
#
echo "[$I/$STEPS] Activating bash tweaks"
echo "  Bash tweaks sets shell prompt to something like \"[11:36]dvinokurov@DVinokurov-WorkPC[~]$\"."
echo "  You could customize colors for date and current working dir (CWD) in this prompt."
ask_color date 3 Green PS_DATE_COLOR_STR
sed -i "s#export PS_DATE_COLOR=.*#export PS_DATE_COLOR=$PS_DATE_COLOR_STR#" ~/$BTWDIR/$BTWMAIN
ask_color CWD 5 Blue PS_CWD_COLOR_STR
sed -i "s#export PS_CWD_COLOR=.*#export PS_CWD_COLOR=$PS_CWD_COLOR_STR#" ~/$BTWDIR/$BTWMAIN
if grep "source ~/$BTWDIR/$BTWMAIN" ~/.bashrc 2>&1 >/dev/null
then
    echo "  Main tweak file '~/$BTWDIR/$BTWMAIN' already included in '~/.bashrc', nothing to do"
else
    echo "  Including main tweak file '~/$BTWDIR/$BTWMAIN' to '~/.bashrc'"
    echo "source ~/$BTWDIR/$BTWMAIN" >> ~/.bashrc
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate MC tweaks
#
echo "[$I/$STEPS] Activating MC tweaks"
sed -i 's#use_internal_edit=false#use_internal_edit=true#' ~/.config/mc/ini
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate Nano tweaks
#
echo "[$I/$STEPS] Activating Nano tweaks"
if [ -f $NANOCONF_SYSTEM_PATH ]
then
    read -p "  File $NANOCONF_SYSTEM_PATH already exists, overwrite? (y/N): " CONFIRM
    if [[ "$CONFIRM" == "y" ]]
    then
        echo "  Overwriting"
        cp $NANOCONF $NANOCONF_SYSTEM_PATH
    else
        echo "  Skipping"
    fi
else
    cp $NANOCONF $NANOCONF_SYSTEM_PATH
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

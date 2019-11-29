#!/bin/bash

set -e
BTWMAIN=main.sh
BTWCOLORS=colors.sh
BTWREPO=bash-tweaks-etc
BTWDIR=.bash-tweaks
MC_DEFAULT_CONFIG=mc.ini.default
NANO_CONFIG=nanorc
NANO_CONFIG_SYSTEM_PATH="$HOME/.nanorc"
MC_CONFIG_SYSTEM_PATH="$HOME/.config/mc/ini"
printf -v CUR_DATETIME_STAMP '%(%Y-%m-%d_%H-%M-%S)T' -1
I=1
STEPS=5

PS_DATE_COLOR_STR=""
PS_CWD_COLOR_STR=""
OVERWRITE=ask
SUPPORTED_COLORS='black, red, green, yellow, blue, purple, cyan, white'

function show_help
{
    echo "Usage: $0 [-h] [-d COLOR] [-c COLOR] [-o]"
    echo
    echo "        -h            - help"
    echo "        -d COLOR      - set bash prompt date color, supported colors: $SUPPORTED_COLORS"
    echo "        -c COLOR      - set bash prompt CWD color, supported colors: $SUPPORTED_COLORS"
    echo "        -o true|false - overwrite configs or not (default is ask)"
}

function hr_color_to_code
{
    HR_COLOR=$1
    TARGET_VARIABLE_NAME=$2
    case "$HR_COLOR" in
    "black")
        COLOR_STR="\$BBlack"
        ;;
    "red")
        COLOR_STR="\$BRed"
        ;;
    "green")
        COLOR_STR="\$BGreen"
        ;;
    "yellow")
        COLOR_STR="\$BYellow"
        ;;
    "blue")
        COLOR_STR="\$BBlue"
        ;;
    "purple")
        COLOR_STR="\$BPurple"
        ;;
    "cyan")
        COLOR_STR="\$BCyan"
        ;;
    "white")
        COLOR_STR="\$BWhite"
        ;;
    *)
        echo "Invalid color \"$HR_COLOR\", available are: $SUPPORTED_COLORS"
        exit 1
        ;;
    esac
    eval "$TARGET_VARIABLE_NAME='$COLOR_STR'"
}

function ask_color
{
    PURPOSE=$1
    DEFAULT_COLOR_NUM=$2
    DEFAULT_COLOR=$3
    TARGET_VARIABLE_NAME=$4
    echo "  Choose color for $PURPOSE:"
    . "$PWD/$BTWCOLORS"
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
# Parse command line args
#
OPTIND=1
while getopts 'hd:c:o:' opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    d)  hr_color_to_code "$OPTARG" PS_DATE_COLOR_STR
        ;;
    c)  hr_color_to_code "$OPTARG" PS_CWD_COLOR_STR
        ;;
    o)  OVERWRITE=$OPTARG
        ;;
    esac
done
# echo $PS_DATE_COLOR_STR
# exit

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
mkdir -p "$HOME/$BTWDIR"
echo "  Copying config files to '$BTWDIR'"
echo "    $BTWMAIN"
cp "$BTWMAIN" "$HOME/$BTWDIR"
echo "    $BTWCOLORS"
cp "$BTWCOLORS" "$HOME/$BTWDIR"
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate bash tweaks
#
echo "[$I/$STEPS] Activating bash tweaks"
echo "  Bash tweaks sets shell prompt to something like \"[11:36]dvinokurov@DVinokurov-WorkPC[~]$\"."
echo "  You could customize colors for date and current working dir (CWD) in this prompt."
if [ -z $PS_DATE_COLOR_STR ]
then
    ask_color date 3 Green PS_DATE_COLOR_STR
else
    echo "  Used date color from command line args: $PS_DATE_COLOR_STR"
fi
sed -i "s#export PS_DATE_COLOR=.*#export PS_DATE_COLOR=$PS_DATE_COLOR_STR#" "$HOME/$BTWDIR/$BTWMAIN"
if [ -z $PS_CWD_COLOR_STR ]
then
    ask_color CWD 5 Blue PS_CWD_COLOR_STR
else
    echo "  Used CWD color from command line args: $PS_CWD_COLOR_STR"
fi
sed -i "s#export PS_CWD_COLOR=.*#export PS_CWD_COLOR=$PS_CWD_COLOR_STR#" "$HOME/$BTWDIR/$BTWMAIN"
if grep "source \"\$HOME/$BTWDIR/$BTWMAIN\"" ~/.bashrc 2>&1 >/dev/null
then
    echo "  Main tweak file '~/$BTWDIR/$BTWMAIN' already included in '~/.bashrc', nothing to do"
else
    echo "  Including main tweak file '~/$BTWDIR/$BTWMAIN' to '~/.bashrc'"
    echo "source \"\$HOME/$BTWDIR/$BTWMAIN\"" >> ~/.bashrc
fi
echo "  Tweaking history sizes in '~/.bashrc'"
sed -i -E 's#((export )?HISTSIZE).*#\1=10000#' ~/.bashrc
sed -i -E 's#((export )?HISTFILESIZE).*#\1=10000#' ~/.bashrc
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate MC tweaks
#
MC_CONFIG_BACKUP_PATH=${MC_CONFIG_SYSTEM_PATH}_${CUR_DATETIME_STAMP}.bak
echo "[$I/$STEPS] Activating MC tweaks"
if [ -f "$MC_CONFIG_SYSTEM_PATH" ]
then
    echo "  MC config found, tweaking it (backup saved to \"$MC_CONFIG_BACKUP_PATH\")"
    cp "$MC_CONFIG_SYSTEM_PATH" "$MC_CONFIG_BACKUP_PATH"
    sed -i 's#use_internal_edit=false#use_internal_edit=true#' $MC_CONFIG_SYSTEM_PATH # For new versions
    sed -i 's#use_internal_edit=0#use_internal_edit=1#' $MC_CONFIG_SYSTEM_PATH # For old versions
    sed -i 's#editor_fill_tabs_with_spaces=false#editor_fill_tabs_with_spaces=true#' $MC_CONFIG_SYSTEM_PATH
else
    echo "  MC config not found, copying default one"
    mkdir -p `dirname "$MC_CONFIG_SYSTEM_PATH"`
    cp "$MC_DEFAULT_CONFIG" "$MC_CONFIG_SYSTEM_PATH"
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Activate Nano tweaks
#
NANO_CONFIG_BACKUP_PATH=${NANO_CONFIG_SYSTEM_PATH}_${CUR_DATETIME_STAMP}.bak
echo "[$I/$STEPS] Activating Nano tweaks"
if [ -f "$NANO_CONFIG_SYSTEM_PATH" ]
then
    if [ $OVERWRITE = 'ask' ]
    then
        read -p "  File $NANO_CONFIG_SYSTEM_PATH already exists, overwrite? (y/N): " CONFIRM
    elif [ $OVERWRITE = 'true' ]
    then
        CONFIRM=y
    else
        CONFIRM=n
    fi
    if [[ "$CONFIRM" == "y" ]]
    then
        echo "  Overwriting existing config (backup saved to \"$NANO_CONFIG_BACKUP_PATH\")"
        cp "$NANO_CONFIG_SYSTEM_PATH" "$NANO_CONFIG_BACKUP_PATH"
        cp "$NANO_CONFIG" "$NANO_CONFIG_SYSTEM_PATH"
    else
        echo "  Config already exists, skipping"
    fi
else
    cp "$NANO_CONFIG" "$NANO_CONFIG_SYSTEM_PATH"
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

#!/bin/bash
# "BASH tweaks etc"
#
# Copyleft 2017-2019
# GPL v3 License or later
# Author: Dmitriy Vinokurov
# Email: gim6626@gmail.com
# Questions and contributions are welcome at https://github.com/Gim6626/bash-tweaks-etc

set -e
BTWMAIN=main.sh
BTWCOLORS=colors.sh
BTWREPO=bash-tweaks-etc
BTWDIR=.bash-tweaks
MC_DEFAULT_CONFIG=mc.ini.default
NANO_CONFIG=nanorc
NANO_CONFIG_SYSTEM_PATH="$HOME/.nanorc"
VIM_CONFIG=vimrc
VIM_CONFIG_SYSTEM_PATH="$HOME/.vim/vimrc"
MC_CONFIG_SYSTEM_PATH="$HOME/.config/mc/ini"
MAILCAP_CONFIG_SYSTEM_PATH="$HOME/.mailcap"
CUR_DATETIME_STAMP=`date '+%Y-%m-%d_%H-%M-%S'`
I=1
STEPS=5

CUSTOM_EDITOR=""

PS_DATE_COLOR_STR=""
PS_CWD_COLOR_STR=""
OVERWRITE=ask
MC_SKIN=""
MC_SKINS_DIR="/usr/share/mc/skins/"
SUPPORTED_COLORS='black, red, green, yellow, blue, purple, cyan, white'
SUPPORTED_EDITORS='nano, mcedit, vim, emacs'

function show_help
{
    echo "Usage: $0 [-h] [-d COLOR] [-c COLOR] [-m MC_SKIN] [-o]"
    echo
    echo "        -h            - help"
    echo "        -d COLOR      - set bash prompt date color, supported colors: $SUPPORTED_COLORS"
    echo "        -c COLOR      - set bash prompt CWD color, supported colors: $SUPPORTED_COLORS"
    echo "        -e EDIT_CMD   - set console editor command, supported editors: $SUPPORTED_EDITORS"
    echo "        -o true|false - overwrite configs or not (default is ask)"
    echo "        -m MC_SKIN    - choose from \"${MC_SKINS_DIR}\", type without \".ini\" and path, only file name"
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

function check_mc_skin_name()
{
    SKIN_NAME=$1
    if [ -f "${MC_SKINS_DIR}/${SKIN_NAME}.ini" ]
    then
        return 0
    else
        return 1
    fi
}

#
# Parse command line args
#
OPTIND=1
while getopts 'hd:c:o:m:e:' opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    d)  hr_color_to_code "$OPTARG" PS_DATE_COLOR_STR
        ;;
    c)  hr_color_to_code "$OPTARG" PS_CWD_COLOR_STR
        ;;
    o)  OVERWRITE=$OPTARG
        ;;
    e)  case "$OPTARG" in
            nano|vim|emacs)
                CUSTOM_EDITOR="$OPTARG"
                ;;
            mcedit)
                CUSTOM_EDITOR="mcedit --skin=\$MC_SKIN"
                ;;
            *)
                echo "Invalid editor, supported are: $SUPPORTED_EDITORS"
                exit 1
                ;;
        esac
        ;;
    m)  MC_SKIN=$OPTARG
        if ! check_mc_skin_name $MC_SKIN
        then
            echo "Error: Bad skin name \"${MC_SKIN}\", check \"${MC_SKINS_DIR}\" directory and try again"
            exit 1
        fi
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
    sed -i 's#editor_tab_spacing=.*#editor_tab_spacing=4#' $MC_CONFIG_SYSTEM_PATH
else
    echo "  MC config not found, copying default one"
    mkdir -p `dirname "$MC_CONFIG_SYSTEM_PATH"`
    cp "$MC_DEFAULT_CONFIG" "$MC_CONFIG_SYSTEM_PATH"
fi
echo "  MC skin customization"
if [ -z "$MC_SKIN" ]
then
    while true
    do
    echo "    Skins examples:"
    echo "    1. \"default\", FAR-like blue-white"
    echo "    2. Light yellow theme \"sand256\" (*)"
    echo "    3. Dark \"darkfar\""
    echo "    4. Prettier dark \"xoria256\" (*)"
    echo "    5. Soft dark \"modarin256\" (*)"
    echo "    6. Other (you can choose from \"${MC_SKINS_DIR}\")"
    echo "    (*) - 256 colors terminal required, it is quite common, but rare on some terminals MC may fall back to default theme"
    read -p "    Enter your choice: " MC_SKIN_CHOICE
    case "$MC_SKIN_CHOICE" in
        "1")
            MC_SKIN="default"
            break
            ;;
        "2")
            MC_SKIN="sand256"
            break
            ;;
        "3")
            MC_SKIN="darkfar"
            break
            ;;
        "4")
            MC_SKIN="xoria256"
            break
            ;;
        "5")
            MC_SKIN="modarin256"
            break
            ;;
        "6")
            read -p "    Type skin name, chosen from \"${MC_SKINS_DIR}\" without \".ini\" and path, only file name: " MC_SKIN
            if check_mc_skin_name $MC_SKIN
            then
                break
            else
                echo "    Error: Bad skin name \"${MC_SKIN}\", check \"${MC_SKINS_DIR}\" directory and try again"
                continue
            fi
            ;;
        *)
            echo "    Error: Wrong choice, try again"
            continue
            ;;
        esac
    done
    echo "    Using selected MC skin: $MC_SKIN"
else
    echo "    Using MC skin from command line args: $MC_SKIN"
fi
sed -i "s#export MC_SKIN=.*#export MC_SKIN='$MC_SKIN'#" "$HOME/$BTWDIR/$BTWMAIN"
echo "[$I/$STEPS] Done"
I=$((I+1))

#
# Setup editor
#
echo "[$I/$STEPS] Setting up editor"
if [ -z "${CUSTOM_EDITOR}" ]
then
    echo "  Choose editor"
    while true
    do
        echo "    Examples:"
        echo "    1. \"nano\" - most simple and suitable for everyone"
        echo "    2. \"mcedit\" - a bit more functional but not complicated"
        echo "    3. \"vim\" - most functional but complicated, for true UNIX fans"
        echo "    4. \"emacs\" - another one most functional but complicated, for true GNU fans"
        read -p "    Enter your choice: " MC_SKIN_CHOICE
        case "$MC_SKIN_CHOICE" in
            "1")
                CUSTOM_EDITOR="nano"
                break
                ;;
            "2")
                CUSTOM_EDITOR="mcedit --skin=\$MC_SKIN"
                break
                ;;
            "3")
                CUSTOM_EDITOR="vim"
                break
                ;;
            "4")
                CUSTOM_EDITOR="emacs"
                break
                ;;
            *)
                echo "    Error: Wrong choice, try again"
                continue
                ;;
        esac
    done
    echo "    Using selected custom editor: $CUSTOM_EDITOR"
fi
echo "export EDITOR=\"$CUSTOM_EDITOR\"" >> "$HOME/$BTWDIR/$BTWMAIN"
echo "  Adding custom editor settings to \"$HOME/$BTWDIR/$BTWMAIN\""
MAILCAP_CONFIG_NEEDS_REWRITE='false'
MAILCAP_CONFIG_SYSTEM_BACKUP_PATH=${MAILCAP_CONFIG_SYSTEM_PATH}_${CUR_DATETIME_STAMP}.bak
MAILCAP_CONFIG_PREV_EXISTED='false'
if [ -f "$MAILCAP_CONFIG_SYSTEM_PATH" ]
then
    MAILCAP_CONFIG_PREV_EXISTED='true'
    if [ $OVERWRITE = 'ask' ]
    then
        read -p "  File $MAILCAP_CONFIG_SYSTEM_PATH already exists, overwrite? (y/N): " CONFIRM
    elif [ $OVERWRITE = 'true' ]
    then
        CONFIRM=y
    else
        CONFIRM=n
    fi
    if [[ "$CONFIRM" == "y" ]]
    then
        MAILCAP_CONFIG_NEEDS_REWRITE='true'
    else
        echo "  Config already exists, skipping"
    fi
else
    MAILCAP_CONFIG_NEEDS_REWRITE='true'
fi
if [ "${MAILCAP_CONFIG_NEEDS_REWRITE}" == 'true' ]
then
    if [ "${MAILCAP_CONFIG_PREV_EXISTED}" == 'true' ]
    then
        echo "  Overwriting Mailcap config (backup saved to \"$MAILCAP_CONFIG_SYSTEM_BACKUP_PATH\")"
    else
        echo "  Adding Mailcap custom editor settings to \"$HOME/$BTWDIR/$BTWMAIN\""
    fi
    echo -n '' > "${MAILCAP_CONFIG_SYSTEM_PATH}"
    CUSTOM_EDITOR_EXPANDED=`echo $CUSTOM_EDITOR | sed "s#\\$MC_SKIN#$MC_SKIN#"`
    echo "text/*; less %s; edit=$CUSTOM_EDITOR_EXPANDED %s; needsterminal" >> "${MAILCAP_CONFIG_SYSTEM_PATH}"
    echo "application/x-sh; less %s; edit=$CUSTOM_EDITOR_EXPANDED %s; needsterminal" >> "${MAILCAP_CONFIG_SYSTEM_PATH}"
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

#
# Activate Vim tweaks
#
VIM_CONFIG_BACKUP_PATH=${VIM_CONFIG_SYSTEM_PATH}_${CUR_DATETIME_STAMP}.bak
echo "[$I/$STEPS] Activating Vim tweaks"
if [ -f "$VIM_CONFIG_SYSTEM_PATH" ]
then
    if [ $OVERWRITE = 'ask' ]
    then
        read -p "  File $VIM_CONFIG_SYSTEM_PATH already exists, overwrite? (y/N): " CONFIRM
    elif [ $OVERWRITE = 'true' ]
    then
        CONFIRM=y
    else
        CONFIRM=n
    fi
    if [[ "$CONFIRM" == "y" ]]
    then
        echo "  Overwriting existing config (backup saved to \"$VIM_CONFIG_BACKUP_PATH\")"
        cp "$VIM_CONFIG_SYSTEM_PATH" "$VIM_CONFIG_BACKUP_PATH"
        cp "$VIM_CONFIG" "$VIM_CONFIG_SYSTEM_PATH"
    else
        echo "  Config already exists, skipping"
    fi
else
    mkdir -p `dirname "$VIM_CONFIG_SYSTEM_PATH"`
    cp "$VIM_CONFIG" "$VIM_CONFIG_SYSTEM_PATH"
fi
echo "[$I/$STEPS] Done"
I=$((I+1))


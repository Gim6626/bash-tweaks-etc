#!/bin/bash

set -e
BTWMAIN=main.sh
BTWCOLORS=colors.sh
BTWREPO=bash-tweaks-etc
BTWDIR=.bash-tweaks
I=1
STEPS=3

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
echo "[$I/$STEPS] Installing bash tweaks"
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
if grep "source ~/$BTWDIR/$BTWMAIN" ~/.bashrc 2>&1 >/dev/null
then
  echo "  Main tweak file '~/$BTWDIR/$BTWMAIN' already included in '~/.bashrc', nothing to do"
else
  echo "  Including main tweak file '~/$BTWDIR/$BTWMAIN' to '~/.bashrc'"
  echo "source ~/$BTWDIR/$BTWMAIN" >> ~/.bashrc
fi
echo "[$I/$STEPS] Done"
I=$((I+1))

# TODO: Add Vim, Nano configs and maybe something else

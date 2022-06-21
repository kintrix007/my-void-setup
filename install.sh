#!/bin/bash

# Set up root environment + system packages 
sudo ./root-install.sh

if [[ $? != 0 ]]; then
	echo Aborted.
	exit
fi

CONF=./config

# Set up bash profile
cp -v $CONF/.bash_profile ~/

# Set up bashrc
cp -v $CONF/.bashrc ~/

# Set up bash aliases
cp -v $CONF/.bash_aliases ~/

# Set up xinitrc
cp -v $CONF/.xinitrc ~/

# Add 'xbps-updates' utility script to PATH
cp -v $CONF/xbps-updates ~/.local/bin/

# Add 'switch-kb-layout' utility to PATH
cp -v $CONF/switch-kb-layout ~/.local/bin

# Setting up graphical session
builddir=~/bin
mkdir -p ~/.config/xmonad
git clone https://github.com/kintrix007/my-xmonad-setup ~/.config/xmonad
mkdir -p $builddir
pushd $builddir
git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib
stack init
stack install
ln -s $builddir/stack.yaml ~/.config/xmonad
popd

# Install flatpak packages
packages=`sed s/#.*// ./flatpak-list`
flatpak install flathub $packages -y

echo
echo ".-------------------------------------------."
echo "| Please reboot to fully apply the changes. |"
echo "'-------------------------------------------'"

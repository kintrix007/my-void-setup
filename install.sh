#!/bin/bash

# Set up root environment + system packages 
sudo ./root-install.sh

if [[ $? != 0 ]]; then
	echo Aborted.
	exit
fi

CONF=./config

# Copy config files to home directory
cp -v $CONF/.bash_profile ~/
cp -v $CONF/.bashrc ~/
cp -v $CONF/.bash_aliases ~/
cp -v $CONF/.flatpak_aliases ~/
cp -v $CONF/.xinitrc ~/

# Add 'xbps-updates' utility script to PATH
cp -v $CONF/xbps-updates ~/.local/bin/

# Add 'switch-kb-layout' utility to PATH
cp -v $CONF/switch-kb-layout ~/.local/bin

# Setting up graphical session
builddir=~/bin
mkdir -p ~/.config/
git clone https://github.com/kintrix007/my-xmonad-setup ~/.config/xmonad
git clone https://github.com/kintrix007/my-rofi-setup ~/.config/rofi
mkdir -p $builddir
pushd $builddir
git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib
stack init
stack install
ln -s $builddir/stack.yaml ~/.config/xmonad
popd

# Set up 'void-packages' with 'xbps-src'
git clone https://github.com/void-linux/void-packages.git ~/void-packages
pushd ~/void-packages
echo 'XBPS_ALLOW_RESTRICTED=yes' > etc/conf
./xbps-src binary-bootstrap
#./xbps-src pkg msttcorefonts
popd

# Install flatpak packages
packages=`sed s/#.*// ./flatpak-list`
# Installing with a for loop to prevent simply installing 'flathub'
for $pack in $packages; do
	flatpak install flathub $pack -y --noninteractive
done

echo
echo ".-------------------------------------------."
echo "| Please reboot to fully apply the changes. |"
echo "'-------------------------------------------'"

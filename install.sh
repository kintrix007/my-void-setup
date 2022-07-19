#!/bin/bash

# For user services
mkdir ~/service

# Set up root environment + system packages 
sudo ./root-install.sh "$USER"

if [[ $? != 0 ]]; then
	echo Aborted.
	exit
fi

# Finalize setting up nix
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# Setting up flatpak user part
flatpak install --noninteractive flathub org.gtk.Gtk3theme.{Arc{,-Dark},Breeze,Adwaita-dark}
flatpak override --env="GTK_THEME=Arc-Dark" --user # There is a better way
# See: https://docs.flatpak.org/en/latest/desktop-integration.html#theming

# Copy desktop entries
mkdir -p ~/.local/share/applications/
cp ./applications/* ~/.local/share/applications/

# Setting up dotfiles
git clone https://github.com/kintrix007/dotfiles ~/dotfiles
~/dotfiles/install.sh

# Setting up graphical session
builddir=~/bin/xmonad
#mkdir -p ~/.config/
#git clone https://github.com/kintrix007/my-xmonad-setup ~/.config/xmonad
#git clone https://github.com/kintrix007/my-rofi-setup ~/.config/rofi
mkdir -p $builddir
pushd $builddir
git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib
stack init
stack install
ln -s $builddir/stack.yaml ~/.config/xmonad
popd

# Setting up xbps-src
git clone https://github.com/void-linux/void-packages.git ~/void-packages
pushd ~/void-packages
echo 'XBPS_ALLOW_RESTRICTED=yes' > etc/conf
./xbps-src binary-bootstrap
#./xbps-src pkg msttcorefonts
popd

# Install flatpak packages
packages=`sed s/#.*// ./flatpak-list`
# Installing with a for loop to prevent simply installing 'flathub'
for pack in $packages; do
	flatpak install --noninteractive flathub $pack
done

echo
echo " .-------------------------------------------. "
echo " |   Make sure to switch to NetworkManager.  | "
echo " | - - - - - - - - - - - - - - - - - - - - - | "
echo " | Please reboot to fully apply the changes. | "
echo " '-------------------------------------------' "

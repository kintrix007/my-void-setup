#!/bin/bash

. helpers.sh

# Make copies so that the originals stay unmodified
XBPS_TEMP=`mktemp`
FLATPAK_TEMP=`mktemp`
cp xbps-list $XBPS_TEMP
cp flatpak-list $FLATPAK_TEMP

# Ask the user to select the desired packages
${EDITOR:-vi} $XBPS_TEMP
${EDITOR:-vi} $FLATPAK_TEMP

# Install selected packages
sudo --preserve-env="USER,HOME,XBPS_TEMP" ./root-post-install.sh

# Install user-specified flatpak packages
flatpak-install-from $FLATPAK_TEMP

# Download and install itch Desktop client
pushd `mktemp -d`
OUTFILE="itch-setup-linux-amd64.zip"
wget "https://broth.itch.ovh/itch-setup/linux-amd64/1.26.0/archive/default" -O "$OUTFILE" -q
unzip "$OUTFILE" -d ~/.local/bin/
~/.local/bin/itch-setup --silent
popd

# Run config of dotfiles
~/dotfiles/install.sh -c

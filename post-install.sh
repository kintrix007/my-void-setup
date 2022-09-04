#!/bin/bash

. helpers.sh

# Make copies so that the originals stay unmodified
cp xbps-list xbps-list.tmp
cp flatpak-list flatpak-list.tmp

# Ask the user to select the desired packages
${EDITOR:-vi} xbps-list.tmp
${EDITOR:-vi} flatpak-list.tmp

# Install selected packages
sudo ./root-post-install.sh

# Install user-specified flatpak packages
flatpak-install-from flatpak-list.tmp

# Remove the temporary files
rm xbps-list.tmp flatpak-list.tmp

# Download and install itch Desktop client
pushd `mktemp -d`
OUTFILE="itch-setup-linux-amd64.zip"
wget "https://broth.itch.ovh/itch-setup/linux-amd64/1.26.0/archive/default" -O "$OUTFILE" -q
unzip "$OUTFILE" -d ~/.local/bin/
~/.local/bin/itch-setup --silent
popd

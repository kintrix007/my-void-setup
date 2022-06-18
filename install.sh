#!/bin/bash

# Set up root environment + system packages 
sudo ./root-install.sh

# Set up bash profile
cat << EOF > ~/.bash_profile
# .bash_profile
# Get the aliases and functions
[ -f \$HOME/.bashrc ] && . \$HOME/.bashrc
# Add local bin directory to PATH
export PATH=\$PATH:\$HOME/.local/bin
EOF

# Set up bashrc
cat << EOF > ~/.bashrc
# .bashrc
# if not running interactively, don't do anything
[[ \$- != *i* ]] && return
# Load user aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
# Set defaul editor
export EDITOR=vim
# Set console prompt
PS1='\[\e[1m\][\[\e[92m\]\u\[\e[0m\]@\[\e[1;92m\]\h \[\e[94m\]\W\[\e[0;1m\]]\$ \[\e[0m\]'
EOF

# Set up bash aliases
cat << EOF > ~/.bash_aliases
# .bash_aliases

alias ll='ls -lA'

# flatpak aliases
#alias firefox='flatpak run org.mozilla.firefox'
EOF

# Set up xinitrc
cat << EOF > ~/.xinitrc
	exec xmonad
EOF

# Source bashrc so at least bashrc is immediately active
. ~/.bashrc

# Install flatpak packages
packages=`sed s/#.*// ./flatpak-packages`
for pack in $packages; do
	flatpak install flathub $pack -y
done

echo
echo ".-------------------------------------------."
echo "| Please reboot to fully apply the changes. |"
echo "'-------------------------------------------'"

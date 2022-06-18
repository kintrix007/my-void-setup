#!/bin/bash

sudo ./install.sh

cat << EOF > ~/.bash_profile
# .bash_profile
# Get the aliases and functions
[ -f \$HOME/.bashrc ] && . \$HOME/.bashrc
# Add local bin directory to PATH
export PATH=\$PATH:\$HOME/.local/bin
EOF

cat << EOF > ~/.bashrc
# .bashrc
# if not running interactively, don't do anything
[[ \$- != *i* ]] && return
# Load user aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
# Set defaul editor
export EDITOR=vim
# Set console prompt
PS1='\[\e[1m\]'['\[\e[[92m\]'\u'\[\e[0m\]'@'\[\e[1;92m\]'\h '\[\e[94m\]'\W'\[\e[1m\]']\$ '\[\e[0m\]'
EOF


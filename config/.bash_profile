# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Define an environment variable for the default terminal
export TERMINAL=alacritty

# Add local bin directory to PATH
export PATH=$PATH:$HOME/.local/bin

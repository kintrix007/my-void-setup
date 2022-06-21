#!/bin/bash

# Set up root environment + system packages 
sudo ./root-install.sh

if [[ $? != 0 ]]; then
	echo Aborted.
	exit
fi

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

# Some useful aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lA'

# flatpak aliases
alias firefox='flatpak run org.mozilla.firefox'
EOF


# Set up xinitrc
cat << EOF > ~/.xinitrc
pipewire &
exec dbus-run-session -- xmonad
EOF

# Add 'xbps-updates' utility script to PATH
cat << EOF > ~/.local/bin/xbps-updates
#!/bin/bash

packages=\`xbps-install -Sun | tr -s " " | cut -d' ' -f2 | tr $'\\n' ' '\`
if [[ "\$1" == "-c" ]] || [[ "\$1" == "--count" ]]; then
	echo \$packages | wc -w
else
	echo \$packages
fi
EOF

# Add 'switch-kb-layout' utility to PATH
cat << EOF > ~/.local/bin/switch-kb-layout
#!/bin/bash

# Load layouts from the config file
LAYOUTS=\`sed 's/#.*//' ~/.kblayouts 2>/dev/null\`

# Set a default if it does not exist
[[ "\$?" != 0 ]] && LAYOUTS='us hu'

cycle() {
	local next=no
	for lay in \$LAYOUTS; do
		if [[ "\$next" == yes ]]; then
			setxkbmap \$lay
			echo \$lay
			return
		fi
		[[ "\$lay" == "\$1" ]] && next=yes
	done

	local first=\`echo \$LAYOUTS | cut -d' ' -f1\`
	setxkbmap \$first
	echo \$first
}

current=\`setxkbmap -query | grep layout | tr -s ' ' | cut -d' ' -f2\`

# If there is an argument, choose that layout
# Otherwise cicle through them
if [[ -n "\$1" ]]; then
	if [[ "\$LAYOUTS" =~ .*"\$1".*  ]]; then
		setxkbmap $1
		echo \$1
	else
		echo "'\$1' is not added as a layout in  '~/.kblayouts'"
		exit 1
	fi
else
	cycle "\$current"
fi
EOF


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
for pack in $packages; do
	flatpak install flathub $pack -y
done

echo
echo ".-------------------------------------------."
echo "| Please reboot to fully apply the changes. |"
echo "'-------------------------------------------'"




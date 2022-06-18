#!/bin/bash

# Update xbps
xbps-install -Suy
if [[ $? != 0 ]]; then
	sudo xbps-install -uy xbps
	xbps-install -Suy
fi

# Add build-in repos
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
xbps-install -S

# Add and enable services
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} isc-ntpd tlp dbus elogind`
xbps-install -y socklog-void snooze ntp tlp dbus elogind

for serv in $services; do
	[[ -f /var/service/$serv ]] || ln -s /etc/sv/$serv /var/service/$serv
	sv up $serv
done

# Set up bash environment
xbps-install bash_completion

cat << EOF > /etc/bash/bashrc.d/bash_completion.sh
# bash_completion.sh

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
EOF

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

# Set up weekly fstrim
[[ -d /etc/cron.weekly ]] || mkdir /etc/cron.weekly/
cat << EOF > /etc/cron.weekly/fstrim
#!/bin/sh

fstrim /
EOF
chmod +x /etc/cron.weekly/fstrim

# Set up flatpak
xbps-install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Set up graphical interface
xbps-install -y xorg xinit dmenu stack

cat << EOF > ~/.xinitrc
exec xmonad
EOF


# Install user packages
packages=`sed s/#.*// ./sys-packages`
xbps-install -y $packages

packages=`sed s/#.*// ./flatpak-packages`
for pack in $packages; do
	flatpak install flathub $pack -y
done


#!/bin/bash

# Update xbps
xbps-install -Suy
if [[ $? != 0 ]]; then
	sudo xbps-install -uy xbps
	xbps-install -Suy
fi

# Add build-in repos
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Install some packages
xbps-install -y git bash-completion

# Add and enable services
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} isc-ntpd tlp dbus elogind`
xbps-install -y socklog-void snooze ntp tlp dbus elogind

for serv in $services; do
	[[ ! -L /var/service/$serv ]] && ln -s /etc/sv/$serv /var/service/
	sv up $serv
done

# Set up bash environment
cat << EOF > /etc/bash/bashrc.d/bash_completion.sh
# bash_completion.sh

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
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
echo Adding flathub...
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install packages for graphical interface
xbps-install -y xorg xinit dmenu pipewire

# Xmonad build dependencies
xbps-install -y gcc stack ncurses-libtinfo-libs ncurses-libtinfo-devel libX11-devel libXft-devel libXinerama-devel libXrandr-devel libXScrnSaver-devel pkg-config
ln -s /lib/libncurses.so.6.* /lib/libtinfo.so.6

# Install user packages
packages=`sed s/#.*// ./xbps-list`
xbps-install -y $packages
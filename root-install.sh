#!/bin/bash

# Set up hu and nl mirrors
[[ -d /etc/xbps.d ]] || mkdir -p /etc/xbps.d

cat << EOF > /etc/xbps.d/nl-repositories.conf.bak
repository=https://void.cijber.net/current
repository=https://void.cijber.net/current/nonfree
EOF

cat << EOF > /etc/xbps.d/hu-repositories.conf.bak
repository=https://quantum-mirror.hu/mirrors/pub/voidlinux/current
repository=https://quantum-mirror.hu/mirrors/pub/voidlinux/current/nonfree
EOF

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
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} isc-ntpd tlp dbus elogind bluetoothd`
xbps-install -y socklog-void snooze ntp tlp dbus elogind bluez

for serv in $services; do
	[[ -L /var/service/$serv ]] || ln -s /etc/sv/$serv /var/service/
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

# Set up daily xbps repository syncing
[[ -d /etc/cron.daily ]] || mkdir /etc/cron.daily/
cat << EOF > /etc/cron.daily/xbps-sync
#!/bin/bash

xbps-install -S
EOF
chmod +x /etc/cron.daily/xbps-sync

# Set up flatpak
xbps-install -y flatpak
echo Adding flathub...
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install packages for graphical interface
xbps-install -y xorg xinit dmenu xmobar pipewire libspa-bluetooth

# Xmonad build dependencies
xbps-install -y gcc stack ncurses-libtinfo-libs ncurses-libtinfo-devel libX11-devel libXft-devel libXinerama-devel libXrandr-devel libXScrnSaver-devel pkg-config
ln -s /lib/libncurses.so.6.* /lib/libtinfo.so.6

# Install user packages
packages=`sed s/#.*// ./xbps-list`
xbps-install -y $packages &

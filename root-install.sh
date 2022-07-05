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
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} \
	isc-ntpd tlp dbus elogind bluetoothd rtkit polkitd \
	popcorn`
	
xbps-install -y socklog-void snooze ntp tlp dbus elogind bluez \
	rtkit polkit \
	PopCorn

for serv in $services; do
	[[ -L /var/service/$serv ]] || ln -s /etc/sv/$serv /var/service/
	sv up $serv
done

# Set up NetworkManager
xbps-install -y NetworkManager network-manager-applet
touch /etc/sv/NetworkManager/down
ln -s /etc/sv/NetworkManager /var/service/

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

# Set up pipewire
xbps-install -y pipewire alsa-pipewire wireplumber pamixer pulsemixer libspa-bluetooth
mkdir /etc/pipewire
cp /usr/share/pipewire/pipewire.conf /etc/pipewire/
sed -i 's|{ path = "/usr/bin/pipewire-media-session" args = "" }|{ path = "/usr/bin/wireplumber" args = "" }\n    { path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|' /etc/pipewire/pipewire.conf
# The following would probably do the same, but likely less stable
#sudo sed -i 's|{ path = "/usr/bin/pipewire-media-session" args = "" }|{ path = "/usr/bin/wireplumber" args = "" }|' /etc/pipewire/pipewire.conf
#sudo sed -i 's|#{ path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|{ path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|' /etc/pipewire/pipewire.conf
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

# Install packages for graphical interface
xbps-install -y xmobar xorg picom xinit rofi rofi-calc rofi-emoji papirus-icon-theme \
	lxsession xdg-utils xdg-user-dirs xdg-desktop-portal xsel

# Install fonts
xbps-install -y noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji noto-fonts-ttf-extra font-fira-ttf font-firacode liberation-fonts-ttf fonts-roboto-ttf font-adobe-source-code-pro ttf-ubuntu-font-family

# Xmonad build dependencies
xbps-install -y gcc stack ncurses-libtinfo-libs ncurses-libtinfo-devel libX11-devel libXft-devel libXinerama-devel libXrandr-devel libXScrnSaver-devel pkg-config
ln -s /lib/libncurses.so.6.* /lib/libtinfo.so.6

# Dependencies for xbps-src
xbps-install -y curl
xbps-pkgdb -m manual curl

# Set up flatpak
xbps-install -y flatpak
echo Adding flathub...
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install user packages
packages=`sed s/#.*// ./xbps-list`
xbps-install -y $packages
xbps-pkgdb -m manual $packages -v

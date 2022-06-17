#!/bin/bash

# Update xbps
xbps-install -Suy || sudo xbps-install -uy xbps
xbps-install -uy

# Add build-in repos
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Add and enable services
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} isc-ntpd tlp dbus elogind`
xbps-install -y socklog-void snooze ntp tlp dbus elogind

for serv in $services; do
	[[ -f /var/service/$serv ]] || ln -s /etc/sv/$serv /var/service/$serv
	sv up $serv
done

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
xbps-install -y xorg xinit ghc xmonad xmonad-contrib dmenu

cat << EOF > ~/.xinitrc
exec xmonad
EOF


# Install user packages
PACKAGES=`sed s/#.*// ./packages`
xbps-install -y $PACKAGES

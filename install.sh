#!/bin/bash

# Update xbps
sudo xbps-install -Suy || sudo xbps-install -uy xbps
sudo xbps-install -uy

# Add build-in repos
sudo xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Add and enable services
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} isc-ntpd tlp dbus elogind`
sudo xbps-install -y socklog-void snooze ntp tlp dbus elogind

for serv in $services; do
	sudo ln -s /etc/sv/$serv /var/service/
	sudo sv up $serv
done

# Set up weekly fstrim
[[ -d /etc/cron.weekly ]] || sudo mkdir /etc/cron.weekly/
cat << EOF | sudo tee /etc/cron.weekly/fstrim > /dev/null
#!/bin/sh

fstrim /
EOF
sudo chmod +x /etc/cron.weekly/fstrim

# Set up flatpak
sudo xbps-install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Set up graphical interface
sudo xbps-install -y xorg xinit ghc xmonad xmonad-contrib dmenu

cat << EOF > ~/.xinitrc
exec xmonad
EOF


# Install user packages
PACKAGES=`sed s/#.*// ./packages`
sudo xbps-install -y $PACKAGES

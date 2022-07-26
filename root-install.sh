#!/bin/bash

USER="$1"

xbps-install-from() {
	local FILE="$1"
	local contents=`sed s/#.*// $FILE | tr $'\n' ' ' | tr -s ' '`
	
	if ! [[ -n $contents ]]; then
		echo "Error: File '$FILE' is empty"
		return
	fi

	xbps-install -y $contents
	xbps-pkgdb -m manual $contents -v
}

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

# Set up user services
cat << EOF > /etc/sv/runsvdir-"$USER"
#!/bin/sh

export USER="$USER"
export HOME="/home/\$USER"

groups="\$(id -Gn "\$USER" | tr ' ' ':')"
svdir="\$HOME/service"

exec chpst -u "\$USER:\$groups" runsvdir "\$svdir"
EOF
ln -s /etc/sv/runsvdir-"$USER" /var/service/

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

# Set up weekly nix garbage collection
[[ -d /etc/cron.weekly ]] || mkdir /etc/cron.weekly/
cat << EOF > /etc/cron.weekly/nix-collect-garbage
#!/bin/sh

# Delete all profiles older than 30 days
# as it's unlikely to be needed
nix-collect-garbage --delete-older-than 30d

# The following would make all rollbacks impossible instantly
#nix-collect-garbage -d
EOF
chmod +x /etc/cron.weekly/nix-collect-garbage

# Set up daily xbps repository syncing
[[ -d /etc/cron.daily ]] || mkdir /etc/cron.daily/
cat << EOF > /etc/cron.daily/xbps-sync
#!/bin/bash

xbps-install -S
EOF
chmod +x /etc/cron.daily/xbps-sync


# Update xbps
xbps-install -Suy
if [[ $? != 0 ]]; then
	sudo xbps-install -uy xbps
	xbps-install -uy
fi

# Add built-in repos
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Install required system packages
xbps-install-from system-packages

# Enable services
services=`echo socklog-unix nanoklogd snooze-{hourly,daily,weekly,monthly} \
	isc-ntpd tlp dbus elogind bluetoothd rtkit polkitd \
	popcorn`

for serv in $services; do
	[[ -L /var/service/$serv ]] || ln -s /etc/sv/$serv /var/service/
done

# Set up pipewire
mkdir /etc/pipewire
cp /usr/share/pipewire/pipewire.conf /etc/pipewire/
sed -i 's|{ path = "/usr/bin/pipewire-media-session" args = "" }|{ path = "/usr/bin/wireplumber" args = "" }\n    { path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|' /etc/pipewire/pipewire.conf
# The following would probably do the same, but likely less stable
#sudo sed -i 's|{ path = "/usr/bin/pipewire-media-session" args = "" }|{ path = "/usr/bin/wireplumber" args = "" }|' /etc/pipewire/pipewire.conf
#sudo sed -i 's|#{ path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|{ path = "/usr/bin/pipewire" args = "-c pipewire-pulse.conf" }|' /etc/pipewire/pipewire.conf
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

# Xmonad build dependencies
ln -s /lib/libncurses.so.6.* /lib/libtinfo.so.6

# Set up flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists kdeapps https://distribute.kde.org/kdeapps.flatpakrepo

# Set up nixpkgs
ln -s /etc/sv/nix-daemon /var/service/

# Install user packages
${EDITOR:-vi} xbps-list
xbps-install-from xbps-list

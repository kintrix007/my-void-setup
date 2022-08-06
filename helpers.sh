# Helpers.sh

function xbps-install-from() {
	local FILE="$1"
	local contents=`sed s/#.*// $FILE | tr $'\n' ' ' | tr -s ' '`

	if ! [[ -n "$contents" ]]; then
		echo "Error: File '$FILE' is empty"
		return
	fi

	xbps-install -y $contents
	xbps-pkgdb -m manual $contents -v
}

function flatpak-install-from() {
	local FILE="$1"
	local contents=`sed s/#.*// $FILE | tr $'\n' ' ' | tr -s ' '`

	if ! [[ -n "$contents" ]]; then
		echo "Error: File '$FILE' is empty"
		return
	fi

	flatpak install --noninteractive flathub $contents
}

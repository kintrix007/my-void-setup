#!/bin/bash

source ./helpers.sh

echo $XBPS_TEMP
[[ -z "$XBPS_TEMP" ]] && exit 1

# Install user-specified xbps packages
xbps-install-from $XBPS_TEMP

ln -s /usr/bin/code-oss /usr/bin/code

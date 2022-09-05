#!/bin/bash

source ./helpers.sh

[[ -z "$XBPS_TEMP" ]] && exit 1

# Install user-specified xbps packages
xbps-install-from $XBPS_TEMP

#!/bin/bash

source ./helpers.sh

# Install user-specified xbps packages
xbps-install-from ./xbps-list.tmp

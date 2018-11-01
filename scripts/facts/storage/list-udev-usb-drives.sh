#!/bin/sh

# This script returns the list of physical drives, connected via
# USB, probably in external enclosures, that may be susceptible
# to overheating when working continuously. Example result:
#
#   /dev/sdf
#
# Note it is NOT SAFE to rely entirely on this script to
# protect against connecting USB devices, as it doesn't detect
# eg. many USB multi-drive enclosures, drives connected through
# Addonics USB-eSATA bridges etc.
#

ls /dev/disk/by-path/*usb* 2>/dev/null |grep -v -- -part |xargs -r -n 1 readlink -f

#!/bin/sh

# This script returns list of ordinary ATA/SATA/USB drives,
# handled by udevd. It doesn't cover drives attached to any
# hardware RAID controllers.

ls /dev/disk/by-id/ata-* /dev/disk/by-id/usb-* 2>/dev/null |grep -v -- -part |grep -v VBOX |grep -v QEMU |grep -v VMware |grep -v CF_CARD |grep -v Cruzer |grep -v DataTraveler |grep -v DVD

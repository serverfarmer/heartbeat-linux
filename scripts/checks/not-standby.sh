#!/bin/sh

devices=`/opt/heartbeat/scripts/facts/storage/list-udev-drives.sh |grep -v SSD |grep -vxFf /etc/heartbeat/skip-smart.sata`

file=`mktemp -u /var/cache/heartbeat/usb.XXXXXXXXX.tmp`
/opt/heartbeat/scripts/facts/storage/list-usb-drives.sh >$file

for device in $devices; do
	devname=`readlink -f $device`
	if grep -qxF $devname $file && [ "`hdparm -C $device 2>&1 |grep standby`" = "" ]; then
		echo $device
	fi
done

rm -f $file

#!/bin/sh

# TODO: support more drive vendors for SAS/SCSI

# related links:
# http://sg.danny.cz/scsi/lsscsi.html
# http://sg.danny.cz/sg/
# https://serverfault.com/questions/718654/can-i-detect-hardware-raid-infromation-from-inside-linux
# https://unix.stackexchange.com/questions/261740/checking-hardware-raid-status-live
# https://hwraid.le-vert.net/wiki/LSIMegaRAIDSAS

for path in `ls /dev/sg* 2>/dev/null`; do
	device=`basename $path`
	vendor=`cat /sys/class/scsi_generic/$device/device/vendor`

	if [ "$vendor" = "SEAGATE " ] || [ "$vendor" = "FUJITSU " ]; then
		echo scsi:$path
	elif [ "$vendor" = "ATA     " ] && [ ! -d /sys/class/scsi_generic/$device/device/block ]; then
		echo sat:$path
	fi
done

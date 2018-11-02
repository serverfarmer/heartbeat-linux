#!/bin/bash

path=`mktemp -d /var/cache/heartbeat/smart.XXXXXX`
devices=`/opt/heartbeat/scripts/facts/storage/list-udev-drives.sh |grep -vxFf /etc/heartbeat/skip-smart.sata`

for device in $devices; do
	base="`basename $device`"
	file="$path/`echo $base |tr ':' '-'`.txt"
	deviceid=${base:4}

	smartctl -d sat -T permissive -a $device >$file.new

	if grep -q "No such device" $file.new || grep -q "Read Device Identity failed" $file.new; then
		logger -p cron.notice -t heartbeat-smart "device $deviceid failed SMART data collection"
	else
		mv -f $file.new $file 2>/dev/null
		/opt/heartbeat/scripts/checks/smart-sata.sh $deviceid $file
	fi
done


raid=`cat /etc/heartbeat/detected-raid-drives.conf |grep -vFf /etc/heartbeat/skip-smart.raid`

for entry in $raid; do
	type=$(echo $entry |cut -d: -f1)
	node=$(echo $entry |cut -d: -f2)
	handle=$(echo $entry |cut -d: -f3)
	device=$(echo $entry |cut -d: -f4)

	file="$path/$device.txt"
	smartctl -d $handle -a $node >$file
	/opt/heartbeat/scripts/checks/smart-$type.sh ${device:4} $file
done


if [ "$1" != "--debug" ]; then
	if [ -x /etc/heartbeat/hooks/smart.sh ]; then
		for file in `ls $path/*.txt 2>/dev/null`; do
			/etc/heartbeat/hooks/smart.sh $file
		done
	fi

	rm -rf $path
fi

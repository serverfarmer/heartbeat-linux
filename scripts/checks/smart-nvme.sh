#!/bin/bash

deviceid=$1
file=$2

reasons=""


lookup_nvme_attribute() {
	name=$1
	reference=$2
	value=`grep "$name" $file |head -n1 |cut -d':' -f2 |awk '{ print $1 }' |sed s/0x//g`

	if [ "$value" != "" ] && [ $value -gt $reference ]; then
		increase=`grep ^$deviceid: /etc/heartbeat/known-smart-defects.conf |grep ":$name:" |cut -d: -f3 |sed 's/[^0-9]*//g'`
		if [ "$increase" = "" ]; then
			reasons="$reasons, $name=$value"
		elif [ $value -gt $increase ]; then
			reasons="$reasons, $name=$value (previously increased to $increase)"
		fi
	fi
}


lookup_nvme_attribute temperature 65
lookup_nvme_attribute critical_warning 0
lookup_nvme_attribute media_errors 10
lookup_nvme_attribute power_on_hours 25000   # nearly 3 years is enough for most NVMe drives...

if [ "$reasons" != "" ]; then
	logger -p cron.notice -t heartbeat-smart "aborting heartbeat for drive $deviceid: ${reasons:2}"
	exit 0
fi

echo smart-$deviceid

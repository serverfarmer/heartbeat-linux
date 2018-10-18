#!/bin/bash

deviceid=$1
file=$2

reasons=""


lookup_smart_attribute() {
	name=$1
	reference=$2
	value=`grep $name $file |head -n1 |awk '{ print $10 }' |cut -dh -f1`

	if [ "$value" != "" ] && [ $value -gt $reference ]; then
		increase=`grep ^$deviceid: /etc/heartbeat/known-smart-defects.conf |grep :$name: |cut -d: -f3 |sed 's/[^0-9]*//g'`
		if [ "$increase" = "" ]; then
			reasons="$reasons, $name=$value"
		elif [ $value -gt $increase ]; then
			reasons="$reasons, $name=$value (previously increased to $increase)"
		fi
	fi
}


if [ "`echo $deviceid |grep SSD`" = "" ]; then
	maxtemp=48
else
	maxtemp=55
fi

lookup_smart_attribute Temperature_Celsius $maxtemp
lookup_smart_attribute Reallocated_Sector_Ct 0
lookup_smart_attribute End-to-End_Error 0
lookup_smart_attribute UDMA_CRC_Error_Count 0
lookup_smart_attribute Spin_Retry_Count 0
lookup_smart_attribute Runtime_Bad_Block 10
lookup_smart_attribute Current_Pending_Sector 2
lookup_smart_attribute Reported_Uncorrect 0
lookup_smart_attribute Offline_Uncorrectable 0
lookup_smart_attribute Calibration_Retry_Count 0
lookup_smart_attribute Power_On_Hours 70000   # 8 years is enough for any drive...

if [ "$reasons" != "" ]; then
	logger -p cron.notice -t heartbeat-smart "aborting heartbeat for drive $deviceid: ${reasons:2}"
	exit 0
fi

echo smart-$deviceid

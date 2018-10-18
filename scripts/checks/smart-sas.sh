#!/bin/bash
# partially based on https://github.com/zmielna/smart_diskinfo

deviceid=$1
file=$2

reasons=""


lookup_sas_attribute() {
	keyword=$1
	column=$2
	name=$3
	reference=$4
	value=`grep "$keyword" $file |awk "{ print \\$$column }" |cut -d. -f1`

	if [ "$value" != "" ] && [ $value -gt $reference ]; then
		increase=`grep ^$deviceid: /etc/heartbeat/known-smart-defects.conf |grep :$name: |cut -d: -f3 |sed 's/[^0-9]*//g'`
		if [ "$increase" = "" ]; then
			reasons="$reasons, $name=$value"
		elif [ $value -gt $increase ]; then
			reasons="$reasons, $name=$value (previously increased to $increase)"
		fi
	fi
}


lookup_sas_attribute "Elements in grown defect list:" 6 reallocated-sectors 4
lookup_sas_attribute "Non-medium error count:"        4 non-medium-errors   10
lookup_sas_attribute "number of hours powered up"     7 power-on-hours      70000

if grep -q "IBM-ESXS" $file; then
	lookup_sas_attribute "^read:"                     2 read-errors         6
	lookup_sas_attribute "^write:"                    2 write-errors        2
	lookup_sas_attribute "^verify:"                   2 verify-errors       2
else
	lookup_sas_attribute "^read:"                     3 read-errors         6
	lookup_sas_attribute "^write:"                    2 fast-write-errors   0
	lookup_sas_attribute "^write:"                    3 write-errors        2
	lookup_sas_attribute "^verify:"                   3 verify-errors       2
fi

if [ "$reasons" != "" ]; then
	logger -p cron.notice -t heartbeat-smart "aborting heartbeat for SAS drive $deviceid: ${reasons:2}"
	exit 0
fi

echo smart-$deviceid

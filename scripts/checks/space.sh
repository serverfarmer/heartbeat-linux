#!/bin/sh

dirs=`cat /etc/heartbeat/detected-data-directories.conf |grep -v ^# |grep -v ^$ |sort |uniq`

for dir in $dirs; do
	/opt/heartbeat/scripts/checks/space-check.sh $dir 12288000  # 12GB
done

/opt/heartbeat/scripts/checks/space-check.sh /boot 81920  # 80MB
/opt/heartbeat/scripts/checks/space-check.sh / 524288  # 512MB

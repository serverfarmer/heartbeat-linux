#!/bin/bash

seconds=`echo 'show slave status\G' |mysql 2>/dev/null |grep Seconds_Behind_Master |awk '{ print $2 }'`

if [ "$seconds" != "" ] && [[ $seconds =~ ^[0-9]+$ ]] && [ "$seconds" -lt 300 ]; then
	echo "mysql-replication"
fi

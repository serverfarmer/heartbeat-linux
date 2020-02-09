#!/bin/sh

max=$1
cur=`cat /proc/loadavg |cut -d' ' -f1`

if [ "$max" != "" ]; then
	ret=`echo "$cur<$max" |bc -l`

	if [ "$ret" = 1 ]; then
		echo "load-below-$max"
	fi
fi

#!/bin/sh

if [ -x /usr/sbin/smartctl ]; then
	smartctl --scan |grep -v /dev/cd |grep "ATA device" |awk '{ print $3 ":" $1 }'
fi

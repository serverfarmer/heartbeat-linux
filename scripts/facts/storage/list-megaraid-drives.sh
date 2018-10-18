#!/bin/sh

if [ -x /usr/sbin/smartctl ]; then
	/usr/sbin/smartctl --scan |grep megaraid |awk '{ print $3 ":" $1 }'
fi

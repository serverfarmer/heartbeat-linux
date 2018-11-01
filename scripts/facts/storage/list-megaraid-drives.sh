#!/bin/sh

if [ -x /usr/sbin/smartctl ] || [ -x /usr/local/sbin/smartctl ]; then
	smartctl --scan |grep megaraid |awk '{ print $3 ":" $1 }'
fi

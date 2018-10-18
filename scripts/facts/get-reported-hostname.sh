#!/bin/sh

if [ -f /etc/farmconfig ]; then
	. /etc/farmconfig
	echo $HOST
else
	hostname
fi

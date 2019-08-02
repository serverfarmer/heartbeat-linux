#!/bin/sh

# hostname set by Server Farmer
if [ -f /etc/farmconfig ]; then
	. /etc/farmconfig
	echo $HOST

# cloud instance id/managed hostname (anything that can be autodiscovered)
elif [ -s /etc/heartbeat/managed.hostname ]; then
	cat /etc/heartbeat/managed.hostname

# classic hostname, if nothing better is found
else
	hostname
fi

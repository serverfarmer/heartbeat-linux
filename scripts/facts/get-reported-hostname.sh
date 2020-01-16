#!/bin/sh

# cloud instance id/managed hostname (autodiscovered during setup)
if [ -s /etc/heartbeat/managed.hostname ]; then
	cat /etc/heartbeat/managed.hostname

# hostname set by Server Farmer
elif [ -f /etc/farmconfig ]; then
	. /etc/farmconfig
	echo $HOST

# classic hostname, if nothing better is found
else
	hostname
fi

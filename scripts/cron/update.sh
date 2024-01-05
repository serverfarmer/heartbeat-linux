#!/bin/bash

exec 9>/var/run/heartbeat.lock
if ! flock -n 9; then exit 0; fi


# default timeout options - can be overwritten in /etc/heartbeat/timeout.conf
CT=2
RT=2
MT=3
if [ -s /etc/heartbeat/timeout.conf ]; then
	. /etc/heartbeat/timeout.conf
fi


host=`/opt/heartbeat/scripts/facts/get-reported-hostname.sh`
services=`/opt/heartbeat/scripts/checks/all.sh |tr '\n' ','`


if [ -s /etc/heartbeat/server.url ]; then
	url=`cat /etc/heartbeat/server.url`

elif [ -x /opt/farm/config/get-url-heartbeat.sh ]; then
	url=`/opt/farm/config/get-url-heartbeat.sh`

else
	url="https://serverfarmer.home.pl/heartbeat/"
fi


curl --connect-timeout $CT --retry $RT --retry-max-time $MT -s "$url?host=$host&services=${services::-1}" >/dev/null 2>/dev/null

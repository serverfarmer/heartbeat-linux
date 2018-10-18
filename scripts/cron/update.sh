#!/bin/bash

exec 9>/var/run/heartbeat.lock
if ! flock -n 9; then exit 0; fi

host=`/opt/heartbeat/scripts/facts/get-reported-hostname.sh`
services=`/opt/heartbeat/scripts/checks/all.sh |tr '\n' ','`


if [ -s /etc/heartbeat/server.url ]; then
	url=`cat /etc/heartbeat/server.url`

elif [ -s /opt/farm/scripts/functions.custom ]; then
	. /opt/farm/scripts/functions.custom
	url=`heartbeat_url`

else
	url="https://serverfarmer.home.pl/heartbeat/"
fi

curl --connect-timeout 2 --retry 2 --retry-max-time 3 -s "$url?host=$host&services=${services:1}" >/dev/null 2>/dev/null

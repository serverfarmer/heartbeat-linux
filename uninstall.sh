#!/bin/sh

if grep -q /opt/heartbeat/scripts/cron /etc/crontab; then
	sed -i -e "/\/opt\/heartbeat\/scripts\/cron/d" /etc/crontab
fi

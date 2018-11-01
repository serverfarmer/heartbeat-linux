#!/bin/sh

mkdir -p /var/cache/heartbeat /etc/heartbeat

if [ "`uname`" = "Linux" ] && ! grep -q /var/cache/heartbeat /etc/fstab; then
	echo "setting up cache directory"
	echo "tmpfs /var/cache/heartbeat tmpfs noatime,size=16m 0 0" >>/etc/fstab
	mount /var/cache/heartbeat
fi


if [ ! -f /proc/1/environ ] || ! grep -q lxc /proc/1/environ; then
	echo "setting up SMART configuration files and templates"
	/opt/heartbeat/scripts/setup/configure-smart.sh

	echo "discovering drives connected to RAID controllers"
	/opt/heartbeat/scripts/setup/detect-raid-drives.sh >/etc/heartbeat/detected-raid-drives.conf
fi

echo "discovering directories for disk space monitoring"
/opt/heartbeat/scripts/setup/detect-data-directories.sh >/etc/heartbeat/detected-data-directories.conf


if ! grep -q /opt/heartbeat/scripts/cron/update.sh /etc/crontab; then
	echo "setting up crontab entries"
	echo "*/2 * * * * root /opt/heartbeat/scripts/cron/update.sh" >>/etc/crontab
fi

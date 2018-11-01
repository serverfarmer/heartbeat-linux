#!/bin/sh

/opt/heartbeat/scripts/checks/services.sh
/opt/heartbeat/scripts/checks/space.sh

if [ ! -f /proc/1/environ ] || ! grep -q lxc /proc/1/environ; then
	/opt/heartbeat/scripts/facts/list-docker-containers.sh
	/opt/heartbeat/scripts/facts/list-libvirt-machines.sh
	/opt/heartbeat/scripts/facts/storage/list-mapped-luks-partitions.sh |tr '[:upper:]' '[:lower:]'
	/opt/heartbeat/scripts/checks/smart.sh |tr '_' '-' |tr ':' '-' |tr '[:upper:]' '[:lower:]'
fi

if [ -x /etc/heartbeat/hooks/custom.sh ]; then
	/etc/heartbeat/hooks/custom.sh
fi

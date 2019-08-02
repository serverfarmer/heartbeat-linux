#!/bin/sh

echo "checking for cloud/managed environment"

# Amazon Web Services (mainly ECS)
if [ -d /sys/class/dmi/id ] && grep -qi amazon /sys/class/dmi/id/* 2>/dev/null; then
	curl -s http://instance-data/latest/meta-data/instance-id >/etc/heartbeat/managed.hostname
fi

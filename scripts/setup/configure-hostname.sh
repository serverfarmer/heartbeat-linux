#!/bin/sh

echo "checking for cloud/managed environment"

# Amazon ECS
if [ -f /etc/image-id ] && grep -q ami-ecs /etc/image-id; then
	curl -s http://instance-data/latest/meta-data/instance-id >/etc/heartbeat/managed.hostname
fi

#!/bin/sh

if [ -x /usr/bin/docker ]; then
	/usr/bin/docker ps --format '{{.Names}}' 2>/dev/null
fi

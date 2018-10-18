#!/bin/bash

if [ "$2" = "" ]; then exit 0; fi

directory=$1
require=$2

if [ "$directory" != "/" ]; then
	label="$directory"
else
	label="/rootfs"
fi

space=`df -k $directory |tail -n1 |awk '{ print $4 }'`

if [[ $space -gt $require ]]; then
	echo "space$label" |tr '/' '-'
fi

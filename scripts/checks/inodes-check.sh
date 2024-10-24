#!/bin/bash

if [ "$2" = "" ]; then exit 0; fi

directory=$1
require=$2

if [ "$directory" != "/" ]; then
	label="$directory"
else
	label="/rootfs"
fi

inodes=`df -i $directory |tail -n1 |awk '{ print $4 }'`

if [[ $inodes -gt $require ]]; then
	echo "inodes$label" |tr '/' '-'
fi

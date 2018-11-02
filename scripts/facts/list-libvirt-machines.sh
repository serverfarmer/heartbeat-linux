#!/bin/sh

if [ "`which virsh 2>/dev/null`" != "" ]; then
	virsh list |grep running |awk '{ print "virt-" $2 }'
fi

#!/bin/sh

if [ "`which virsh 2>/dev/null`" != "" ]; then
	virsh list 2>/dev/null |grep running |awk '{ print "virt-" $2 }'
fi

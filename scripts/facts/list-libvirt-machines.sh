#!/bin/sh

if [ "`which virsh`" != "" ]; then
	virsh list |grep running |awk '{ print "virt-" $2 }'
fi

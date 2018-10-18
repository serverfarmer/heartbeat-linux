#!/bin/sh

/usr/sbin/smartctl --scan |grep megaraid |awk '{ print $3 ":" $1 }'

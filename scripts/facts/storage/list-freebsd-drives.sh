#!/bin/sh

ls -1 /dev/ada* 2>/dev/null |grep -E 'ada[0-9]+$' |awk '{ print "auto:" $1 }'

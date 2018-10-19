#!/bin/bash

search=$1
min=$2
label=$3

if [ "$label" != "" ]; then
	count=`ps aux |grep "$search" |grep -v grep |wc -l`

	if [[ $count -ge $min ]]; then
		echo $label
	fi
fi

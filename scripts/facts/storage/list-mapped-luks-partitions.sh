#!/bin/sh

grep dev/mapper/disk- /proc/mounts |sed s/0:0-//g |grep -v : |cut -d' ' -f1 |cut -d'/' -f4

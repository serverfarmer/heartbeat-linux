#!/bin/sh

/usr/sbin/smartctl --scan |grep megaraid |cut -d' ' -f3

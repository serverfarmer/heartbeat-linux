#!/bin/sh

if [ ! -f /etc/heartbeat/skip-smart.sata ]; then
	echo "# devices to skip should be added in the below format:
# /dev/disk/by-id/ata-ST4000DM000-1F2168_W300XXXX
" >/etc/heartbeat/skip-smart.sata
fi

if [ ! -f /etc/heartbeat/skip-smart.raid ]; then
	echo "# devices to skip should be added in the below format:
# sas-ST3600057SS_6SLXXXXX
#
# NO EMPTY LINES IN THIS FILE!
#" >/etc/heartbeat/skip-smart.raid
fi

if [ ! -f /etc/heartbeat/known-smart-defects.conf ]; then
	echo "# example entries:
# ST4000DM000-1F2168_W300XXXX:UDMA_CRC_Error_Count:3
# WDC_WD121KRYZ-01W0RB0_XXXXXXXX:Temperature_Celsius:50
" >/etc/heartbeat/known-smart-defects.conf
fi

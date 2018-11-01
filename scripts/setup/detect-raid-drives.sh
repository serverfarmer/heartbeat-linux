#!/bin/sh

scan_drive() {
	file=$1
	type=$2
	device=$3

	smartctl -d $type -i $device >$file

	if grep -q " SAS" $file; then
		model=`grep 'Product:' $file |awk '{ print $2 $3 $4 $5 $6 $7 $8 $9 }'`
		serial=`grep 'Serial number:' $file |awk '{ print $3 }'`
		echo sas:$device:$type:sas-${model}_${serial}
	elif ! grep -q "INQUIRY failed" $file; then
		model=`grep 'Device Model:' $file |awk '{ print $3 $4 $5 $6 $7 $8 $9 }'`
		serial=`grep 'Serial Number:' $file |awk '{ print $3 }'`
		echo sata:$device:$type:ata-${model}_${serial} |grep -v VBOX |grep -v QEMU |grep -v VMware
	fi
}


file=`mktemp -u /var/cache/heartbeat/raid.XXXXXXXXX.tmp`
drives1=`/opt/heartbeat/scripts/facts/storage/list-megaraid-drives.sh`
drives2=`/opt/heartbeat/scripts/facts/storage/list-scsi-generic-drives.sh`
drives3=`/opt/heartbeat/scripts/facts/storage/list-freebsd-drives.sh`

for drive in $drives1 $drives2 $drives3; do
	type=$(echo $drive |cut -d: -f1)
	device=$(echo $drive |cut -d: -f2)
	scan_drive $file $type $device
done

rm -f $file

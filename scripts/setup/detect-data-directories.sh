#!/bin/sh

# use Server Farmer extension to find local MySQL server
if [ -f /opt/farm/ext/db-utils/functions.mysql ]; then
	. /opt/farm/ext/db-utils/functions.mysql

	user=`mysql_local_user`
	if [ "$user" != "" ]; then
		pass=`mysql_local_password`
		echo 'show variables where variable_name like "datadir"' |mysql -u $user -p$pass 2>/dev/null |grep ^datadir |awk '{ print $2 }'
		echo
	fi
fi

if [ -x /usr/bin/psql ]; then
	cd /tmp
	echo 'show data_directory' |sudo -u postgres psql 2>/dev/null |tr ' ' '\n' |tr '|' '\n' |grep -v ^$ |grep -v -- ------- |grep -A1 -- data_directory |tail -n1
	echo
fi

for dir in `cat /opt/heartbeat/config/common-data-directories.list |grep -v ^#`; do
	if [ -d $dir ] && [ ! -h $dir ] && [ "`ls -A $dir`" != "" ]; then
		echo $dir
	fi
done

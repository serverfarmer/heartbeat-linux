#!/bin/sh

symlink_if_not_exists() {
	src=$1
	dst=$1

	if [ ! -x $dst ] && [ -x $src ]; then
		echo "creating symbolic link from $src to $dst"
		ln -s $src $dst
	fi
}


# FreeBSD
# assume that packages are already installed (bash, curl, flock, smartmontools)
symlink_if_not_exists /usr/local/bin/bash /bin/bash
symlink_if_not_exists /usr/local/bin/curl /usr/bin/curl
symlink_if_not_exists /usr/local/bin/flock /usr/bin/flock
symlink_if_not_exists /usr/local/sbin/smartctl /usr/sbin/smartctl

# NetBSD
# assume that packages are already installed (bash, netcat, smartmontools)
#
# smartmontools package is available in repositories since NetBSD 7.0,
# it has to be installed manually on earlier releases, see README.md file
symlink_if_not_exists /usr/pkg/bin/bash /bin/bash
symlink_if_not_exists /usr/pkg/sbin/nc /bin/nc
symlink_if_not_exists /usr/pkg/sbin/smartctl /usr/sbin/smartctl

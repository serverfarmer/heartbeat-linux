#!/bin/sh

# This script returns list of ordinary NVMe (including NVMe via USB)
# drives, handled by udevd. It doesn't cover drives attached to any
# hardware RAID controllers.

ls /dev/disk/by-id/nvme* 2>/dev/null |grep -v -- -part |grep -v nvme-eui

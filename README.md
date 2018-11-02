## Overview

Heartbeat is a Server Farmer subproject, that extends functionally your chosen monitoring/alerting solution by providing abilities to monitor:
- services listening on known ports
- running Docker containers
- running libvirt-based virtual machines
- SMART for local drives (also SAS and all drives connected through hardware RAID controllers)
- free space under critical directories (eg. `/var/lib/mysql` - directories are detected automatically, see below)
- mounted LUKS encrypted drives (or just any device mapper based)
- custom conditions defined per monitored host

Heartbeat can work with any monitoring/alerting system, that supports http(s) keyword monitoring, including:
- public: StatusCake, Uptimerobot, Pingdom etc.
- local: Nagios, Icinga, Zabbix, PRTG etc.

This versions is compatible with:
- Linux (all distributions, possibly except some minimal ones)
- FreeBSD 9.x or later
- NetBSD 6.x or later


## Installation

Heartbeat can be installed in 2 modes: with or without Server Farmer.

1. With Server Farmer it:
- is installed automatically on all Linux/FreeBSD-based hosts
- installs `/etc/heartbeat/hooks/smart.sh` hook for Cacti and NewRelic (see below)
- uses Heartbeat server address from `heartbeat_url` function (see below)

2. Manual installation without Server Farmer:

```
git clone https://github.com/serverfarmer/heartbeat-linux /opt/heartbeat
/opt/heartbeat/setup.sh
```

Next, put your Heartbeat instance url into `/etc/heartbeat/server.url` file (unless you want to use the public instance, eg. for testing).

### OS specific notes

#### FreeBSD

Make sure that `bash`, `curl`, `flock` and `smartmontools` packages are installed.

#### NetBSD, Slackware

Execute `crontab -e` as root and add this line to crontab:

`*/2 * * * * /opt/heartbeat/scripts/cron/update.sh`

#### NetBSD earlier than 7

Make sure that `bash`, `netcat`, `mozilla-rootcerts` and `smartmontools` packages are installed. Installing `smartmontools` will require changing `PKG_PATH` variable first, to point to release 7 repository, eg.

`PKG_PATH=ftp://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/amd64/7.0/All`

After installing (and each upgrade of) `mozilla-rootcerts` package, execute `mozilla-rootcerts install` as root to refresh CA root certificates.


## How it works

#### Local part:

1. Cron job `/opt/heartbeat/scripts/cron/update.sh` is run every 2 minutes.
2. It runs `/opt/heartbeat/scripts/checks/all.sh` script to collect detected items to report. This script can be also run manually for debugging purposes - it just prints all found items on console.
3. Cron job sends the collected list to Heartbeat server.

##### Heartbeat server address detection:

1. Cron job looks for `/etc/heartbeat/server.url` file - if it exists, it should contain the full path to Heartbeat server.
2. If Server Farmer is also installed, cron job loads `/opt/farm/scripts/functions.custom` file and uses server address returned by `heartbeat_url` function. So if you cloned Server Farmer main repository and changed mentioned function to point to your private instance, it will be automatically detected here.
3. Otherwise it uses hardcoded `https://serverfarmer.home.pl/heartbeat/` (public Heartbeat instance).

#### Remote part:

1. Your chosen monitoring/alerting platform is querying [Heartbeat server](https://github.com/serverfarmer/heartbeat-server) for particular item on particular monitored host.
2. Heartbeat server responds with either `ALIVE` or `DEAD` keyword, where `ALIVE` means that this item was last reported no longer than 270 seconds ago.

Items are reported every 120 seconds, so 270 seconds means tolerance for 1 failed request + up to 30 seconds overall network lag. And this limit can be easily adjusted in repository with server part.

## Query URL format

Assuming that:
- your Heartbeat server has address `http://heartbeat.yourdomain.com/heartbeat/`
- your example monitored host has hostname `yourserver.yourdomain.com`

this is the complete URL that checks for `ssh` service running on this host:

`http://heartbeat.yourdomain.com/heartbeat/query.php?id=ssh_yourserver_yourdomain_com`

Rules:
- everything is converted to lowercase
- underlines, colons and slashes are replaced with dashes
- dots in hostnames are replaced with underlines
- network service names are listed in `/opt/heartbeat/scripts/checks/services.sh` script


## Performance

Single AWS `t2.micro` instance, storing temporary files on `tmpfs` filesystem, can handle over 3000 individual checks without any performance issues, assuming that queries from monitoring system are done via http (no encryption), every 1 minute.

Note that you can use different addresses for reporting data from monitored hosts, and for querying (in particular, you can use https for reporting and http for querying over internal network).


## SMART monitoring details

Heartbeat automatically detects all local drives, even ones not supported by udev:
- SATA drives connected straight, or via USB or eSATA (including with port multiplier), or even as passthrough from hypervisor to virtual machine
- SATA/SAS drives connected to MegaRAID controller
- SATA/SAS drives connected to any custom hardware controller, assuming that such drives are exposed via `/dev/sg*` interfaces

##### Server Farmer hook for Cacti and NewRelic

For each detected and not excluded drive (not necessarily meeting conditions described below), Heartbeat executes `/etc/heartbeat/hooks/smart.sh` script, with the full name of SMART dump file as the only argument. When Heartbeat is installed by Server Farmer, this file is installed automatically, you can however replace it with your own one.

Version provided by Server Farmer:

- parses the SMART dump again and pushes the drive metrics to NewRelic (assuming that `sf-monitoring-newrelic` extension is installed and NewRelic license key is properly configured)
- copies this dump using scp to Cacti server (assuming that `sf-monitoring-cacti` extension is installed)

##### Handling known drive defects

In highly professional use, drives mostly work in stable physical conditions for all their lifetime. This is often not the case for smaller companies or private use, where physical conditions (eg. temperature, cables etc.) can change from time to time.

Because of that, some particular SMART errors can happen and shouldn't be considered a problem. For example,  non-zero `UDMA_CRC_Error_Count` is often a result of bad eSATA cable/connector, and it stays non-zero even after the cable is replaced. And there are numerous similar exceptions, where certain defects doesn't yet mean that drive should be replaced.

In file `/etc/heartbeat/known-smart-defects.conf` you can store such exceptions, eg.:

`WDC_WD121KRYZ-01W0RB0_XXXXXXXX:Temperature_Celsius:50`

means that this particular drive is allowed to run with allowed temperature increased by 2 degrees from standard (which is not recommended anyway, but it's a better solution than simply dropping such drive).

##### Excluding problematic drives

There are certain cases, where you want to exclude particular drives from being detected and checked every 2 minutes, for example:

- unstable RAID controller, causing random system crashes during SMART read attempts
- USB drives in external enclosures, meant to be either disconnected or put in `standby` condition for most of the time, that might overheat otherwise

You can add such drives to these files to exclude them from being detected:
- `/etc/heartbeat/skip-smart.sata` (drives recognized and handled by udev)
- `/etc/heartbeat/skip-smart.raid` (drives connected to hardware RAID controllers)

##### Required SMART conditions for SATA drives

- `Temperature_Celsius` - max 48 degrees for magnetic drives, or 55 degrees for SSD
- `Reallocated_Sector_Ct` - 0
- `End-to-End_Error` - 0
- `UDMA_CRC_Error_Count` - 0
- `Spin_Retry_Count` - 0
- `Runtime_Bad_Block` - max 10
- `Current_Pending_Sector` - max 2
- `Reported_Uncorrect` - 0
- `Offline_Uncorrectable` - 0
- `Calibration_Retry_Count` - 0
- `Power_On_Hours` - max 70000 (which is around 8 years)

##### Required SMART conditions for SAS drives

Drive temperature is not monitored, since SAS drives have Drive Trip Temperature mechanism.

- `Elements in grown defect list` (similar to `Reallocated_Sector_Ct`) - max 4
- `Non-medium error count` (similar to `UDMA_CRC_Error_Count`) - max 10
- ECC-corrected reads - max 6
- ECC-corrected writes - max 2
- ECC-corrected verifications - max 2
- `number of hours powered up` - max 70000 (only for Seagate and Hitachi drives)


## Free space monitoring details

`/opt/heartbeat/config/common-data-directories.list` file contains the list of directories commonly used to storage bigger amounts of data, eg. by databases, queues, (para)virtualization etc. This file is processed during Heartbeat setup and any directories from this list that actually exist on current host, are added to `/etc/heartbeat/detected-data-directories.conf` file. Next, they are checked every 2 minutes, if they have at least 12 GB of free disk space.

Additionally, root filesystem is required to have 512 MB of free space, and `/boot` directory - 80 MB.

Such limits are designed to give system administrators just enough time to safely deal with the problem - not to assure that system will be able to run for next weeks or months. You can however implement your own limits, just by adding the following line to custom check script:

```
/opt/heartbeat/scripts/checks/space-check.sh /var/lib 491520000
```

This example check will require `/var/lib` directory to have at least 480 GB of free space, or otherwise it will fail.


## Implementing custom checks

You can implement custom checks just by adding them to `/etc/heartbeat/hooks/custom.sh` script. It just needs to print the list of passed checks on console, one per line. For example, the above check for `/var/lib` directory free space should just print:

`space-var-lib`

It is important that this script, or scripts/libraries/etc. that you invoke from it, should not print anything else on console - otherwise it will be sent to Heartbeat server and might interfere with other checks.

To simplify your custom logic, you can also use `/opt/heartbeat/scripts/checks/custom/count-processes.sh` script, that counts the processes with given name pattern, eg.:

`/opt/heartbeat/scripts/checks/custom/count-processes.sh app/console 34 my-symfony-app-console`

Such script will print `my-symfony-app-console` if there will be at least 34 running processes with `app/console` in their names. Note that you can use spaces in the first argument

`/opt/heartbeat/scripts/checks/custom/count-processes.sh "app/console rabbitmq:consumer" 31 rabbit-consumer`


## Debugging

To see, what is reported to Heartbeat server, just run:

- `/opt/heartbeat/scripts/checks/all.sh` - to see the list of reported checks (running it with `--debug` argument will disable SMART hook script and removing temporary files with SMART dumps)
- `/opt/heartbeat/scripts/facts/get-reported-hostname.sh` - to see the hostname used for reporting

If you added/removed drives or directories to monitor free space, run `/opt/heartbeat/setup.sh` to scan system for changes.

All Heartbeat settings are stored in `/etc/heartbeat` directory, and temporary files in `/var/cache/heartbeat` (which should be mounted as `tmpfs`).


## How to contribute

We are welcome to contributions of any kind: bug fixes, added code comments,
support for new operating system versions or hardware etc.

If you want to contribute:
- fork this repository and clone it to your machine
- create a feature branch and do the change inside it
- push your feature branch to github and create a pull request


## License

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Tomasz Klim (<opensource@tomaszklim.pl>) |
| **Copyright:**       | Copyright 2016-2018 Tomasz Klim          |
| **License:**         | MIT                                      |

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#!/bin/bash
##
## 20180105
##           To test some THP and kernel memory protection settings.
##           Once tested, these should be part of configuration management,
##           and/or orchestration.
##
##           With no args or "test", settings are ephemeral.
##           With "perm" settings are preserved on reboot.
##
set -o posix
set -u
PATH="/sbin:/usr/sbin:/bin:/usr/sbin";export PATH
LANG=C;LC_ALL=C;S_TIME_FORMAT=ISO;export LANG LC_ALL S_TIME_FORMAT
NOW=`date '+%Y%m%d%H%M%s'`;export NOW
if [ ! -s /etc/centos-release ] ; then
    echo "This does not appear to be CentOS. Sorry."
    exit 2;
fi
##
if [ ${UID} -ne 0 ] ; then
printf "\n\nSorry, this must be run as root.\n\n"
exit 2;
fi
##
## set THP to madvise so it is still there if an app requests it, but off otherwise.
##  to monitor, use
##
#    egrep 'trans|thp' /proc/vmstat
##
#    grep AnonHugePages /proc/meminfo
##
#    sysctl vm.nr_hugepages
##
## or per process
#    grep -e AnonHugePages  /proc/*/smaps | awk  '{ if($2>4) print $0} ' |  awk -F "/"  '{print $0; system("ps -fp " $3)} '
##
##
thptest()
{
echo -n "madvise" > /sys/kernel/mm/transparent_hugepage/enabled
echo -n "never" > /sys/kernel/mm/transparent_hugepage/defrag
}

thpperm()
{
##
## set in grub too
MADCOUNT=`grep -c madvise /proc/cmdline`
if [ ${MADCOUNT} -lt 1 ] ; then
grubby --update-kernel=ALL --remove-args="transparent_hugepage"
grubby --update-kernel=ALL --args="transparent_hugepage=madvise"
fi
##
## Some other things you may want in grub are:
##   intel_pstate=disable edd=off intel_idle.max_cstate=0 processor.max_cstate=0
##   elevator=noop acpi_pad.disable=1 zswap.enabled=1
##
## and
##
##   nopti
## to get your performance back if you do not execute arbitrary or untrusted code.
##
## Be sure to remove this one to get your 128MB back:
##   crashkernel
##
}

## calculate this regardless
MEM=`grep ^MemTotal /proc/meminfo | awk {'print $2'}`
if   [ ${MEM} -gt 2097152000 ] ; then
    MINFREE=32768000
    RESERV=524288
elif [ ${MEM} -gt 1048576000 ] ; then
    MINFREE=16384000
    RESERV=524288
elif [ ${MEM} -gt 524288000 ] ; then
    MINFREE=8192000
    RESERV=524288
elif [ ${MEM} -gt 262144000 ] ; then
    MINFREE=4096000
    RESERV=524288
elif [ ${MEM} -gt 131072000 ] ; then
    MINFREE=1024000
    RESERV=524288
elif [ ${MEM} -gt 1310720 ] ; then
    MINFREE=524288
    RESERV=262144
else
## we may have small VMs
    MINFREE=131072
    RESERV=65536
fi
export MINFREE RESERV


kerntest()
{
##
## sync disks, drop caches, compact mem, then update min_free
## witchcraft sync's from the religion of ohdns.
sync;sync;sync
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/compact_memory
##
## For this to be safe, OS+Apps should leave AT LEAST:
##  64GB free on 1TB+  machines
##  32GB free on 512GB machines
##  16GB free on 256GB machines ... and so on.  AT LEAST...
##
## That leaves some memory for inode/dentry, page cache .. network, disk buffers, etc...
##
## Use https://raw.githubusercontent.com/ohdns/ps_mem/master/ps_mem.py as root to get APP memory
## use free -m before App is up to see OS memory
##
	sysctl -q -w vm.min_free_kbytes=${MINFREE}
##
## Do this regardless.
## These should really be updated in /etc/sysctl.conf as well.
##
## We don't use swap, don't use hueristics to caclulate overcommit.
## "vm.overcommit_memory = 0" Does NOT mean off.
##  2 is off, but causes other issues.
    sysctl -q -w vm.overcommit_ratio=0
##
## valid range, 0 to 10000.  prefer pagecache over inode/dentry cache.
## default is 100 (optimal for file servers).  4000+ for in memory databases.
    sysctl -q -w vm.vfs_cache_pressure=1000
##
## user and admin early evacuation of caches and more.
    sysctl -q -w vm.admin_reserve_kbytes=${RESERV}
    sysctl -q -w vm.user_reserve_kbytes=${RESERV}
##
printf "\n\nOk, now start up your applications.\n\n"
}

## sure, I could do this in one line.  Easier to read this way.
kernperm()
{
sed -i /vm\.overcommit_ratio/d /etc/sysctl.conf
sed -i /vm\.min_free_kbytes/d /etc/sysctl.conf
sed -i /vm\.vfs_cache_pressure/d /etc/sysctl.conf
sed -i /vm\.admin_reserve_kbytes/d /etc/sysctl.conf
sed -i /vm\.user_reserve_kbytes/d /etc/sysctl.conf
sed -i /^##/d /etc/sysctl.conf
sed -i /^$/d /etc/sysctl.conf
sync
#
printf "\n##\n## updated ${NOW} based on ${MEM} memory.\nvm.min_free_kbytes=${MINFREE}\nvm.vfs_cache_pressure=1000\nvm.admin_reserve_kbytes=${RESERV}\nvm.user_reserve_kbytes=${RESERV}\n##\n##\n" >> /etc/sysctl.conf
sync
/sbin/sysctl -e -p > /dev/null 2>&1
}

set +u
case "$1" in

test)
printf "\nSetting THP Test Settings.\n"
thptest;
printf "\nSetting Kernel Test Settings.\n"
kerntest;
;;
perm)
printf "\nSetting THP Grub Perm Settings.\n"
thpperm;
printf "\nSetting Kernel Sysctl Perm Settings.\n"
kernperm;
;;
*)
printf "\nSetting THP Test Settings.\n"
thptest;
printf "\nSetting Kernel Test Settings.\n"
kerntest;
;;

esac

exit 0;
##
## THP articles.  THP will be disabled across the board if using ZDT java.
##
## TL;DR: Set THP to madvise unless you know for a fact you need it.
##
## https://blog.nelhage.com/post/transparent-hugepages/    
## https://access.redhat.com/solutions/46111
## https://tobert.github.io/tldr/cassandra-java-huge-pages.html
## https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/
## https://www.perforce.com/blog/tales-field-taming-transparent-huge-pages-linux
## https://blogs.oracle.com/linux/performance-issues-with-transparent-huge-pages-thp
##

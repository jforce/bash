#!/bin/bash

host=$(hostname)

ARCH=$(uname -m)

which bc
if [ $? -ne 0 ]; then
    echo "This script require GNU bc, cf. http://www.gnu.org/software/bc/"
    echo "On Linux Debian/Ubuntu you can install it by doing : apt-get install bc"
fi

echo "Update sysctl for $host"

mem_bytes=$(awk '/MemTotal:/ { printf "%0.f",$2 * 1024}' /proc/meminfo)
shmmax=$(echo "$mem_bytes * 0.90" | bc | cut -f 1 -d '.')
shmall=$(expr $mem_bytes / $(getconf PAGE_SIZE))
max_orphan=$(echo "$mem_bytes * 0.10 / 65536" | bc | cut -f 1 -d '.')
file_max=$(echo "$mem_bytes / 4194304 * 256" | bc | cut -f 1 -d '.')
max_tw=$(($file_max*2))
min_free=$(echo "($mem_bytes / 1024) * 0.01" | bc | cut -f 1 -d '.')

if [ "$1" != "ssd" ]; then
    vm_dirty_bg_ratio=5
    vm_dirty_ratio=15
else
    # This setup is generally ok for ssd and highmem servers
    vm_dirty_bg_ratio=3
    vm_dirty_ratio=5
fi

>/etc/sysctl.conf cat << EOF

# Disable syncookies (syncookies are not RFC compliant and can use too muche resources)
net.ipv4.tcp_syncookies = 0

# Basic TCP tuning
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_syn_retries = 3

# RFC1337
net.ipv4.tcp_rfc1337 = 1

# Defines the local port range that is used by TCP and UDP
# to choose the local port
net.ipv4.ip_local_port_range = 1024 65535

# Log packets with impossible addresses to kernel log
net.ipv4.conf.all.log_martians = 1

# Minimum interval between garbage collection passes This interval is
# in effect under high memory pressure on the pool
net.ipv4.inet_peer_gc_mintime = 5

# Disable Explicit Congestion Notification in TCP
net.ipv4.tcp_ecn = 0

# Enable window scaling as defined in RFC1323
net.ipv4.tcp_window_scaling = 1

# Enable timestamps (RFC1323)
net.ipv4.tcp_timestamps = 1

# Enable select acknowledgments
net.ipv4.tcp_sack = 1

# Enable FACK congestion avoidance and fast restransmission
net.ipv4.tcp_fack = 1

# Allows TCP to send "duplicate" SACKs
net.ipv4.tcp_dsack = 1

# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# No controls source route verification (RFC1812)
net.ipv4.conf.default.rp_filter = 0

# Enable fast recycling TIME-WAIT sockets
net.ipv4.tcp_tw_recycle = 1

# TODO : change TCP_SYNQ_HSIZE in include/net/tcp.h
# to keep TCP_SYNQ_HSIZE*16<=tcp_max_syn_backlog
net.ipv4.tcp_max_syn_backlog = 20000

# tells the kernel how many TCP sockets that are not attached
# to any user file handle to maintain
net.ipv4.tcp_max_orphans = $max_orphan

# How may times to retry before killing TCP connection, closed by our side
net.ipv4.tcp_orphan_retries = 1

# how long to keep sockets in the state FIN-WAIT-2
# if we were the one closing the socket
net.ipv4.tcp_fin_timeout = 20

# maximum number of sockets in TIME-WAIT to be held simultaneously
net.ipv4.tcp_max_tw_buckets = $max_tw

# don't cache ssthresh from previous connection
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1

# increase Linux autotuning TCP buffer limits
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# increase TCP max buffer size
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

net.core.netdev_max_backlog = 2500
net.core.somaxconn = 65000

vm.swappiness = 20

# You can monitor the kernel behavior with regard to the dirty
# pages by using grep -A 1 dirty /proc/vmstat
vm.dirty_background_ratio = $vm_dirty_bg_ratio
vm.dirty_ratio = $vm_dirty_ratio

# required free memory (set to 1% of physical ram)
vm.min_free_kbytes = $min_free

# system open file limit
fs.file-max = $file_max

# Core dump suidsafe
fs.suid_dumpable = 2

kernel.printk = 4 4 1 7
kernel.core_uses_pid = 1
kernel.sysrq = 0
kernel.msgmax = 65536
kernel.msgmnb = 65536

# Maximum shared segment size in bytes
kernel.shmmax = $shmmax

# Maximum number of shared memory segments in pages
kernel.shmall = $shmall
EOF

sysctl -p /etc/sysctl.conf
PATH="/bin:/usr/bin:/usr/local/bin"

if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
	echo "0,1,2,4,6,15" > /sys/module/lowmemorykiller/parameters/adj
fi

if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
	echo "2560,4096,6144,12288,14336,18432" > /sys/module/lowmemorykiller/parameters/minfree
fi

if [ -e /proc/sys/vm/swappiness ]; then
	echo "20" > /proc/sys/vm/swappiness
fi

if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
	echo "50" > /proc/sys/vm/vfs_cache_pressure
fi

if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
	echo "3000" > /proc/sys/vm/dirty_expire_centisecs
fi

if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
	echo "500" > /proc/sys/vm/dirty_writeback_centisecs
fi

if [ -e /proc/sys/vm/dirty_ratio ]; then
	echo "22" > /proc/sys/vm/dirty_ratio
fi

if [ -e /proc/sys/vm/dirty_background_ratio ]; then
	echo "4" > /proc/sys/vm/dirty_background_ratio
fi



# Percentagem maxima (mude se vc achar q deve) eu deixo em 85%
percent=40

# Total da memoria:
ramtotal=`grep -F "MemTotal:" < /proc/meminfo | awk '{print $2}'`
# Memoria livre:
ramlivre=`grep -F "MemFree:" < /proc/meminfo | awk '{print $2}'`

# RAM utilizada pelo sistema:
ramusada=`expr $ramtotal - $ramlivre`

# Porcentagem de RAM utilizada pelo sistema:
putil=`expr $ramusada \* 100 / $ramtotal`

echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
date
echo
echo "Mem. utilizada: $putil %";

if [ $putil -gt $percent ]
then
   date=`date`
   echo $date >> /var/log/memoria.log
   echo "Mem. utilizada: $putil %" >> /var/log/memoria.log

   echo "Memoria acima de $percent %, cache foi limpa!";
   sync
   # 'Dropando' cache:
   echo 3 > /proc/sys/vm/drop_caches
   echo
    free -m
   echo
echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
else
    echo "Cache nao foi limpa!";
echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    unset percent ramtotal ramlivre ramusada putil
    exit $?
fi

exit $?

#!/bin/rc

cur=`{pwd}

rfork ns
rootspec=other rootdir=/root/usr/knusbaum/rootfs auth/newns rc -c '
	mount -bC -c ''#s/boot'' /oldroot
	bind -b -c /oldroot/'$cur' /9bps
	bind -c /oldroot/usr/'$user'/tmp /tmp
	webfs
	/9bps/pkgbuild
'

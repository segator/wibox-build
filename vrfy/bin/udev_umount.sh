#!/bin/sh
echo udev_umount $1
if [ -x /bin/umount ] ;then

	umount /mnt/$1 >/dev/null 2>&1
	[ -e /mnt/$1 ] && rm /mnt/$1 -rf >/dev/null 2>&1
fi

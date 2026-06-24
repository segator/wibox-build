#!/bin/sh
echo udev_mount $1
[ -e /mnt/$1 ] || /bin/mkdir -p /mnt/$1 >/dev/null 2>&1

mount_err=0

if [ -x /bin/mount ];then

	/bin/mount -t vfat /dev/$1 /mnt/$1 >/dev/null 2>&1
	mount_err=$?

	if [ $mount_err -ne 0 ];then

		/bin/mount -t fat /dev/$1 /mnt/$1 >/dev/null 2>&1
		mount_err=$?
	fi

	if [ $mount_err -ne 0 ];then

		/bin/mount -t msdos /dev/$1 /mnt/$1 >/dev/null 2>&1
		mount_err=$?
	fi
fi

if [ $mount_err -ne 0 ];then

	if [ -x /usr/bin/ntfs-3g ]; then
		/usr/bin/ntfs-3g /dev/$1 /mnt/$1 >/dev/null 2>&1
	fi
fi

#!/bin/sh

#DEV=/dev/sda1
#DEV:='-t nfs -o nolock 172.16.1.36:/tftpboot'
MNT=/var/mnt
DATA_PATH=${MNT}/speed_data

mkdir -p ${MNT}
mount -t nfs -o nolock 172.16.1.36:/tftpboot ${MNT} || exit 0
date

if [ $# = 0 ] ; then
	echo "test write speed ..."
	#dd if=/dev/zero	of=${DATA_PATH} bs=4096	count=131072 #512M
	rm ${DATA_PATH} -rf
	dd if=/dev/zero	of=${DATA_PATH} bs=1M	count=100 #100M
fi

if [ $# = 1 ] ; then
	echo "test read speed ..."
	dd if=${DATA_PATH} of=/dev/null bs=1M count=100
fi
umount ${MNT}
date

#mount ${DEV} ${MNT}
mount -t nfs -o nolock 172.16.1.36:/tftpboot ${MNT} || exit 0

ls -hl ${DATA_PATH}
umount ${MNT}

ls -hl ${MNT}

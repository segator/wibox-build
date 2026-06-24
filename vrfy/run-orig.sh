#ifconfig lo up
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ifconfig eth0 up
ifconfig eth0 192.168.1.10

telnetd &
mkdir -p /mnt/mtd/dropbear 2>/dev/null
dropbear -R 2>/dev/null &

mkdir -p /var/lock
mkdir -p /var/run
mkdir -p /var/fat32_0
mkdir -p /var/cloud

#/usr/ln.sh 

cd /ko/ && ./load710xsdrv.sh

#web
mkdir /var/web
cp /usr/web/index.html /var/web
ln -s /usr/web/* /var/web


#wifi
mkdir /var/wifi
cp /usr/sbin/wifi_conf/* /var/wifi/
cp /usr/sbin/hostapd.conf /var/wifi

mdev -s
cp "/usr/cloud/states" "/var/cloud/states" -f
if ! [ -s /mnt/mtd/Config/npc_nts_client_config.ini ]; then
	echo "npc_nts_client_config.ini is not exist,copy!"
	cp "/usr/cloud/npc_nts_client_config.ini" "/mnt/mtd/Config/npc_nts_client_config.ini" -f
fi

ln -s /etc/sensors/nvp6134_hw.bin /tmp/sensor_hw.bin
#ln -s /etc/display/lcd_hw.bin /tmp/lcd_hw.bin

cp /usr/Sofia.lzma /var
cd /var; tar -x --lzma -f Sofia.lzma
rm /var/Sofia.lzma -rf

/usr/bin/system_sofia &

echo  1084576 > /proc/sys/net/core/rmem_max
echo  1084576 > /proc/sys/net/core/wmem_max

/usr/bin/e2prom_mac

ln -s /mnt/mtd/Config/resolv.conf /var/resolv.conf

#start pppoe
#setsid /usr/sbin/pppoe.sh


#for gdb
#ifconfig eth0 172.16.1.72
#mkdir -p /var/mk
#mount -t nfs -o nolock 172.16.1.71:/nfs  /var/mk
#mkdir -p /var/mk/core/
#echo "core-%e-%s-%u-%g-%p-%t" > /proc/sys/kernel/core_pattern
#cd /var/mk/core && ulimit -c unlimited && chmod 777 ./Sofia && ./Sofia

#for release
echo 3 > /proc/sys/vm/drop_caches; free
echo 0 > /proc/sys/kernel/printk
chmod 777 /var/Sofia
/mnt/mtd/strace -f -e trace=ioctl -o /mnt/mtd/sofia_init.log interDebug /var/Sofia 9527 &


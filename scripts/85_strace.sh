#!/bin/sh
# Strace Sofia directly (bypass interDebug - broken in non-PTY env)
if [ ! -f "${ROOTFS}/run-orig.sh" ]; then
  echo "[*] run-orig.sh not found, skipping"
  exit 0
fi

echo "[*] Adding strace + dropbear to run-orig.sh"
sed -i "/telnetd \&/a\\
mkdir -p /mnt/mtd/dropbear 2>/dev/null\\
dropbear -R 2>/dev/null \&" ${ROOTFS}/run-orig.sh

sed -i "s|interDebug /var/Sofia 9527|/mnt/mtd/strace -f -e trace=ioctl -o /mnt/mtd/sofia_init.log /var/Sofia 9527 \&|" ${ROOTFS}/run-orig.sh

echo "[*] Strace applied (Sofia direct)"
grep strace ${ROOTFS}/run-orig.sh

# WiBox Custom Firmware Builder

Dockerized build environment for [duhow/wibox](https://github.com/duhow/wibox) Fermax WiBox custom firmware.

## Quick Start

```bash
# 1. Build the Docker image
docker build -t wibox-build-tool .

# 2. Copy your original mtd4 backup as 'mtd4' in this directory

# 3. Build the custom firmware
docker run --rm --entrypoint bash \
  -v $(pwd):/work -w /work \
  wibox-build-tool -c 'make all FILE=mtd4'

# 4. Output: release/latest (cramfs image, ~4MB)
```

## What's inside

- **Debian Bullseye** with cramfs tools (cramfsck + mkcramfs)
- All [duhow/wibox](https://github.com/duhow/wibox) patch scripts
- WiFi (wpa_supplicant from factory sbin)
- Telnet (port 23) for recovery

## Flash to WiBox

Via U-boot (YMODEM):
```
mw.b 0xC1000000 ff 00400000
sf probe
loady 0xC1000000
sf erase 0x00460000 00400000
sf write 0xC1000000 0x00460000 00400000
reset
```

## Custom modifications

To add strace tracing on Sofia startup, edit `cramfs/run-orig.sh` after `make extract`:

```bash
sed -i "/telnetd &/a mkdir -p /mnt/mtd/dropbear && dropbear -R &" cramfs/run-orig.sh
sed -i 's|interDebug /var/Sofia 9527|/mnt/mtd/strace -f -e trace=ioctl -o /mnt/mtd/sofia_init.log interDebug /var/Sofia 9527 &|' cramfs/run-orig.sh
```

Then `make build` to rebuild.

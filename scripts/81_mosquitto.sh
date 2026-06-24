#!/bin/sh
set -e

PACKAGE_VERSION=v2.0.14
PACKAGE_DOWNLOAD=https://github.com/eclipse/mosquitto/archive/refs/tags/${PACKAGE_VERSION}.tar.gz
FILE=include/bin/mosquitto_sub

if [ ! -d "include/" ]; then
  echo "[*] Folder include does not exist, skipping."
  exit
fi
if [ -e "${FILE}" ]; then
  echo "[*] mosquitto already built, skipping."
  exit
fi

echo "[*] Downloading mosquitto ${PACKAGE_VERSION}"
wget -q -O mosquitto.tar.gz ${PACKAGE_DOWNLOAD}

mkdir -p mosquitto
tar xf mosquitto.tar.gz -C mosquitto --strip-components=1

echo "[*] Building mosquitto"
make -C mosquitto \
  WITH_THREADING=no WITH_TLS=no WITH_CJSON=no WITH_BRIDGE=no WITH_PERSISTENCE=no \
  WITH_MEMORY_TRACKING=no WITH_DOCS=no WITH_STRIP=yes WITH_STATIC_LIBRARIES=yes \
  WITH_SHARED_LIBRARIES=no CFLAGS="-Wall -Os" \
  CC=arm-goke-linux-uclibcgnueabi-gcc CXX=arm-goke-linux-uclibcgnueabi-g++ \
  AR=arm-goke-linux-uclibcgnueabi-ar

if [ ! -e "mosquitto/client/mosquitto_sub" ]; then
  echo "[!] Build failed!"
  exit 1
fi

echo "[*] Installing"
for NAME in mosquitto_sub mosquitto_pub; do
  cp mosquitto/client/${NAME} include/bin/${NAME}
  arm-goke-linux-uclibcgnueabi-strip include/bin/${NAME}
done
rm -rf mosquitto mosquitto.tar.gz
echo "[*] mosquitto built successfully"

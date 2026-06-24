FROM ghcr.io/duhow/wibox-crosstool:latest

# Cramfs tools built on Ubuntu 16.04 (zlib 1.2.8, compatible with GK710X kernel)
COPY mkcramfs cramfsck /usr/local/bin/
RUN chmod +x /usr/local/bin/mkcramfs /usr/local/bin/cramfsck

# Extra build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    rsync wget bzip2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

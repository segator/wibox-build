FROM ghcr.io/duhow/wibox-crosstool:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git build-essential zlib1g-dev rsync wget bzip2 \
    && git clone --depth 1 https://github.com/npitre/cramfs-tools.git /tmp/ct \
    && cd /tmp/ct && make && cp cramfsck mkcramfs /usr/local/bin/ && rm -rf /tmp/ct \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
ENTRYPOINT ["make"]
CMD ["all"]

FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git build-essential zlib1g-dev make wget bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Build cramfs tools
RUN git clone --depth 1 https://github.com/npitre/cramfs-tools.git /tmp/ct \
    && cd /tmp/ct && make \
    && cp cramfsck mkcramfs /usr/local/bin/ \
    && rm -rf /tmp/ct

WORKDIR /build

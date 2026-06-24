FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    make wget zlib1g rsync file \
    && rm -rf /var/lib/apt/lists/*

COPY cramfsck mkcramfs /usr/local/bin/
RUN chmod +x /usr/local/bin/cramfsck /usr/local/bin/mkcramfs

WORKDIR /build
ENTRYPOINT ["make"]
CMD ["all"]

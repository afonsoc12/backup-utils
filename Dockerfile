FROM alpine:latest

ARG TARGETOS \
    TARGETARCH

ENV XDG_CONFIG_HOME=/config \
    XDG_CACHE_HOME=/config/cache

COPY versions.sh /usr/local/bin/versions

RUN apk add -U --no-cache \
               tzdata \
               fuse \
               rclone \
               rsync \
               openssh-client-default \
               ca-certificates \
               iperf3 \
    && update-ca-certificates \
    && wget https://github.com/restic/restic/releases/download/v0.14.0/restic_0.14.0_${TARGETOS}_${TARGETARCH}.bz2 -O /tmp/restic.bz2 \
    && bzip2 -d /tmp/restic.bz2 \
    && mv /tmp/restic /usr/local/bin/restic \
    && ls -alh /tmp \
    && mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME \
    && echo "user_allow_other" >> /etc/fuse.conf \
    && ln -s /usr/local/bin/versions /usr/local/bin/version \
    && chmod u+x /usr/local/bin/version* /usr/local/bin/restic  \
    && rm -rf /tmp/* /var/{cache,log}/* /var/lib/apt/lists/*

# RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone
CMD ["sh", "-l"]

WORKDIR /data

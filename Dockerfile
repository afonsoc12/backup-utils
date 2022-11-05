FROM alpine:latest

ARG TARGETOS \
    TARGETARCH

ENV XDG_CONFIG_HOME=/config \
    XDG_CACHE_HOME=/config/cache

COPY versions.sh /usr/local/bin/versions

RUN apk add -U --no-cache \
               tzdata \
               tree \
               openssh-client-default \
               ca-certificates \
               rsync \
               rclone \
               restic \
               fuse \
               iperf3 \
    && update-ca-certificates \
    && rclone selfupdate \
    && restic self-update \
    && mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME \
    && echo "user_allow_other" >> /etc/fuse.conf \
    && ln -s /usr/local/bin/versions /usr/local/bin/version \
    && chmod u+x /usr/local/bin/version* \
    && rm -rf /tmp/* /var/{cache,log}/* /var/lib/apt/lists/*

# RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone
CMD ["sh", "-l"]

WORKDIR /data

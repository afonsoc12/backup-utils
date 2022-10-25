FROM alpine:latest

COPY versions.sh /usr/local/bin/versions

ENV XDG_CONFIG_HOME=/config \
    XDG_CACHE_HOME=/config/cache

RUN apk add -U --no-cache \
               tzdata \
               fuse \
               rclone \
               rsync \
               restic \
               openssh-client-default \
               ca-certificates \
               iperf3 \
    && update-ca-certificates \
    && mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME \
    && echo "user_allow_other" >> /etc/fuse.conf \
    && chmod u+x /usr/local/bin/versions \
    && rm -rf /tmp/* /var/{cache,log}/* /var/lib/apt/lists/*

# RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone
CMD ["sh", "-l"]

WORKDIR /data

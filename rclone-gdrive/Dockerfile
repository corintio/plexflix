FROM alpine AS builder

RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip && \
    cp rclone-*-linux-amd64/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

RUN wget -O /usr/bin/mergerfs https://github.com/trapexit/mergerfs/releases/download/2.26.2/mergerfs-static-amd64 && \
    chmod +x /usr/bin/mergerfs

FROM lsiobase/alpine
COPY --from=builder /usr/bin/rclone /usr/bin
COPY --from=builder /usr/bin/mergerfs /usr/bin

RUN apk add --no-cache --update fuse \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

# Default environment variables
ENV CONFIG_FILE="/config/rclone.conf" \
    REMOTE_PATH="gcrypt:" \
    REMOTE_MOUNT="/GD" \
    UPLOAD_PATH="/data/upload" \
    LOCAL_MOUNT="/data/gmedia" \
    RCLONE_LOG_LEVEL="INFO" \
    RCLONE_MOUNT_OPTIONS="--allow-other \
    --attr-timeout 10s \
    --dir-cache-time 96h \
    --drive-chunk-size 32M \
    --timeout 2h \
    --umask 002" \
    RCLONE_UPLOAD_OPTIONS="-c \
    --transfers 3 \
    --checkers 3 \
    --tpslimit 3 \
    --no-traverse \
    --delete-after \
    --drive-chunk-size 32M \
    --delete-empty-src-dirs" \
    MERGERFS_OPTIONS="-o defaults,sync_read,auto_cache,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff" \
    UPLOAD_CRONTAB="* * * * *" \
    UPLOAD_DELAY="5"

COPY root/ /

VOLUME ["/data", "/config", "/logs"]

# Change home folder
WORKDIR /rclone
RUN usermod -d /rclone abc
RUN chown -R abc:abc /rclone
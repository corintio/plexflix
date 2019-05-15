FROM alpine AS builder

RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip
RUN cp rclone-*-linux-amd64/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

# RUN wget https://github.com/trapexit/mergerfs/releases/download/2.26.1/mergerfs-static-amd64 \
#     -O /usr/bin/mergerfs && \
#     chown root:root /usr/bin/mergerfs && \
#     chmod 755 /usr/bin/mergerfs

FROM lsiobase/alpine
COPY --from=builder /usr/bin/rclone /usr/bin/rclone
# COPY --from=builder /usr/bin/mergerfs /usr/bin/mergerfs

RUN apk add --no-cache --update fuse \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ENV CONFIG_FILE="/config/rclone.conf" \
    REMOTE_PATH="gcrypt:" \
    UPLOAD_PATH="/data/upload" \
    LOCAL_MOUNT="/data/gmedia" \
    RCLONE_MOUNT_OPTIONS="--allow-other \
    --attr-timeout 10s \
    --dir-cache-time 96h \
    --drive-chunk-size 32M \
    --timeout 2h \
    --umask 002" \
    RCLONE_UPLOAD_OPTIONS="-c \
    --transfers=10 \
    --checkers=10 \
    --no-traverse \
    --delete-after \
    --drive-chunk-size 32M \
    --delete-empty-src-dirs" \
    UPLOAD_CRONTAB="* * * * *"

COPY root/ /

VOLUME ["/data", "/config", "/logs"]

WORKDIR /data

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/rclone.conf:/config/rclone.conf
# -v /data:/data:shared


# docker build -t rclone . && docker run -it -e REMOTE_PATH=gcrypt:/test --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined rclone bash
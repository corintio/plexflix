FROM alpine AS builder

RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip

RUN cp rclone-*-linux-amd64/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

# Two stages build makes the final image 10MB (23%) smaller 
FROM lsiobase/alpine
COPY --from=builder /usr/bin/rclone /usr/bin/rclone

RUN apk add --no-cache --update fuse unionfs-fuse \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ENV CONFIG_FILE="/config/rclone.conf" \
    REMOTE_PATH="gcrypt:" \
    LOCAL_PATH="/data/upload" \
    LOCAL_MOUNT="/data/gmedia" \
    REMOTE_MOUNT="/data/GD" \
    RCLONE_MOUNT_OPTIONS="--allow-other \
    --dir-cache-time 96h \
    --drive-chunk-size 32M \
    --log-level INFO \
    --log-file /logs/rclone.log \
    --timeout 2h \
    --umask 002 \
    --rc" \
    RCLONE_UPLOAD_OPTIONS="-c \
    --transfers=3 \
    --checkers=3 \
    --tpslimit 3 \
    --delete-after \
    --drive-chunk-size 32M \
    --delete-empty-src-dirs" \
    UNIONFS_OPTIONS="cow,allow_other" \
    UPLOAD_CRONTAB="* * * * *"

ADD scripts /scripts
ADD crontab.txt /crontab.txt
COPY root/ /

VOLUME ["/data", "/config", "/logs"]

WORKDIR /data

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/rclone.conf:/config/rclone.conf
# -v /data:/data:shared
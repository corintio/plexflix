#!/bin/bash
set -e

# docker build -t rclone rclone-gdrive

# docker run -it --cap-add SYS_ADMIN --device /dev/fuse \
# --security-opt apparmor:unconfined \
# -e REMOTE_PATH=gcrypt: -e PUID:`id -u` -e PGID:`id -g` \
# -v ~/.config/rclone:/config -v ~/logs:/logs -v ~/gmedia:/data rclone


mkdir -p ~/gmedia
rclone mount gcrypt: ~/gmedia --log-level INFO --allow-other --attr-timeout 10s --dir-cache-time 96h \
    --drive-chunk-size 32M \
    --timeout 2h \
    --umask 002
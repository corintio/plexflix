#!/bin/sh

# Install docker if not available in this container
which docker && apk add --no-cache docker

# Execute the command rclone sync in the rclone containter
docker exec rclone rclone sync -v \
    --config /rclone/rclone.conf \
    --checksum \
    --transfers 3 \
    --checkers 3 \
    --tpslimit 3 \
    /data/backups gcrypt:/backups
#!/bin/sh

# Install docker if not available in this container
which docker && apk add --no-cache docker

# Execute the command rclone sync in the rclone containter
docker exec rclone rclone sync -v \
    --checksum \
    --config /config/.rclone.conf \
    --transfers=10 \
    --checkers=20 \
    /data/backups gcrypt:/backups
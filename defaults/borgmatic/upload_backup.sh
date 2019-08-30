#!/bin/sh

# Install docker if not available in this container
if ! which docker; then apk add --no-cache docker; fi

# Execute the command rclone sync in the rclone containter
docker exec rclone rclone sync -v \
    --checksum \
    --transfers 3 \
    --checkers 3 \
    --tpslimit 3 \
    /data/backups gcrypt:/backups
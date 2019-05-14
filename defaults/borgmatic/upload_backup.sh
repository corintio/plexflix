#!/bin/sh

if ! which docker; then
    apk add --no-cache docker
fi

docker exec rclone rclone sync -c -v --config /config/.rclone.conf --transfers=10 --checkers=20 /data/backups gcrypt:/backups
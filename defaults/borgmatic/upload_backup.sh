#!/bin/sh

# Install docker if not available in this container
which docker && apk add --no-cache docker

# Execute the command rclone sync in the rclone containter
docker exec rclone rclone sync -v \
    --checksum \
    --transfers=10 \
    --checkers=20 \
    --user-agent "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1" \
    /data/backups gcrypt:/backups
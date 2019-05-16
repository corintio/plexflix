Rclone Gdrive
=============

Rclone mount container, optmized to work with Google Drive. It uses an union mount to keep new files
locally, and uploads them using a cronjob. This is similar to solutions like Plexdrive+UnionFS and 
Rclone+MergeFS, but all code and configuration is self-contained, for easy configuration and testing.

This project is based on:
- https://github.com/animosity22/homescripts
- https://hoarding.me/rclone-scripts/
- https://hub.docker.com/r/mumiehub/rclone-mount


## Usage
By default, the container expects a `rclone.conf` file in the `/config` folder. It will fail if 
the config file is not found. This config must define the remote used to store your data. It
must match the env var REMOTE_PATH


### With Docker
```
$ docker build -t rclone . && docker run -it --cap-add SYS_ADMIN --device /dev/fuse \
--security-opt apparmor:unconfined -e REMOTE_PATH=gcrypt: \
-v /config:/config -e /logs:/logs /data:/data rclone
```

### With Docker Compose
```yml
version: '3.7'
services:
  rclone:
    build : /path/to/rclone-gdrive
    container_name: rclone
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse
    security_opt:
      - apparmor:unconfined
    environment:
      - REMOTE_PATH=gcrypt:
    volumes:
      - ./config:/config
      - ./logs:/logs
      - ./data:/data:shared
    restart: always
```

### Environment Variables and defaults
```
CONFIG_FILE=/config/rclone.conf
REMOTE_PATH=gcrypt:
LOCAL_MOUNT=/data/gmedia
UPLOAD_PATH=/data/upload
UPLOAD_CRONTAB=* * * * *
RCLONE_MOUNT_OPTIONS=--allow-other \
    --attr-timeout 10s \
    --dir-cache-time 96h \
    --drive-chunk-size 32M \
    --timeout 2h \
    --umask 002
RCLONE_UPLOAD_OPTIONS=-c \
    --transfers=10 \
    --checkers=10 \
    --no-traverse \
    --delete-after \
    --drive-chunk-size 32M \
    --delete-empty-src-dirs
```
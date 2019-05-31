Rclone Gdrive
=============

[Rclone](https://rclone.org) mount container, optmized to work with Google Drive and 
write-once, large files (like media files and backup archives). It uses 
[mergerfs](https://github.com/trapexit/mergerfs) to keep new files locally, and 
uploads them using a cronjob. This is similar to solutions using Plexdrive+UnionFS, but 
all code and configuration is self-contained, for easy setup and testing.

What this project provides is nothing new, and has been implemented before many times, 
with this same approach or different solutions (see the *Credits* bellow). The goal of 
this project is to make the setup as straightforward as possible, thanks to the 
encapsulation provided by Docker. 

## Requirements
This has only been tested with Linux. You'll need to have the following software 
installed in your computer:

- **Docker**:
```
sudo curl -L https://get.docker.com | bash
sudo usermod -aG docker $USER
```
- **Fuse**. Installation instructions depend on your Linux flavour. For Ubuntu:
```
sudo apt-get update
sudo apt-get install fuse
```


## Usage
By default, the container expects a `rclone.conf` file in the `/config` folder. It will 
fail if the config file is not found. This config must define the remote used to store 
your data. It must match the env var $REMOTE_PATH (default `gcrypt:`).

It will mount the merged folder in the path defined in the $LOCAL_MOUNT env var 
(default `/data/gmedia`). The local buffer for new files not uploaded yet is located in 
$UPLOAD_PATH (default `/data/upload`). 

New files will be uploaded based on the $UPLOAD_CRONTAB schedule. It will
only upload files that are older than $UPLOAD_DELAY minutes. By default it checks every 
minute for files older than 5 minutes.

Check the *Configuration* Section bellow to see all customizations available.

**NOTE**: You need to specify the following Docker options for this container to work properly:
`--cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined`

### With Docker
```
$ docker build -t rclone .
$ docker run -it --cap-add SYS_ADMIN --device /dev/fuse \
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

### Configuration
Using the following environment variables, you can customize the behaviour of this 
container to your specific needs, change things like paths, schedule, tweaking 
rclone/mergerfs options and log level.

Variable              | Default             | Usage
----------------------|---------------------|------
CONFIG_FILE           | /config/rclone.conf | Path to `rclone` config file (inside the container)
REMOTE_PATH           | gcrypt:             | Name of remote (as defined in `rclone.conf`)
LOCAL_MOUNT           | /data/gmedia        | Location where the merged data will be mounted
UPLOAD_PATH           | /data/upload        | Location where the new files will be stored
UPLOAD_CRONTAB        | * * * * *           | Schedule to check for new files to be uploaded
UPLOAD_DELAY          | 5                   | Minutes from last modification before file is uploaded to the remote
RCLONE_LOG_LEVEL      | INFO                | Log level for all `rclone` commands
RCLONE_MOUNT_OPTIONS  | --allow-other --attr-timeout 10s --dir-cache-time 96h --drive-chunk-size 32M --timeout 2h --umask 002 | Options used for `rclone mount` (to mount the remote locally)
RCLONE_UPLOAD_OPTIONS | -c --transfers=10 --checkers=10 --no-traverse --delete-after --drive-chunk-size 32M --delete-empty-src-dirs | Options used for `rclone move` (to upload files to Google Drive)
MERGERFS_OPTIONS      | -o defaults, sync_read, auto_cache, use_ino, allow_other, func.getattr=newest, category.action= all,category.create=ff | Options used for `mergerfs` to "join" the remote mount with the local files


## Credits
This project *borrows* some ideas from:
- https://github.com/animosity22/homescripts
- https://hoarding.me/rclone-scripts/
- https://hub.docker.com/r/mumiehub/rclone-mount

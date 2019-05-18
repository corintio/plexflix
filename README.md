# PlexFlix

This is my personal Mediaserver installation, based on [Dockerized](http://docker.com) 
apps. 

### Applications (and their respective docker projects):
- Plex - https://github.com/linuxserver/docker-plex
- Sonarr - https://github.com/linuxserver/docker-sonarr
- Radarr - https://github.com/linuxserver/docker-radarr
- Tautulli - https://github.com/linuxserver/docker-tautulli
- Ombi - https://github.com/linuxserver/docker-ombi
- Jackett - https://github.com/linuxserver/docker-jackett
- Caddy+Docker plugin - https://github.com/lucaslorentz/caddy-docker-proxy
- Rclone - [Sub project `rclone-gdrive`](rclone-gdrive)
- Transmission (+VPN) - https://github.com/haugene/docker-transmission-openvpn
- Borgmatic - https://github.com/b3vis/docker-borgmatic
- Watchtower - https://github.com/containrrr/watchtower
- Portainer - https://hub.docker.com/r/portainer/portainer

### Features:
- Fully automated solution, with automatic download for TV shows and movies
- Google Drive integration, for "unlimited" storage in the cloud (encrypted)
- VPN integration for protected torrent downloading
- Automatic SSL (https) certificates generation
- Automatic daily backups using borg (only for configuration and app data, as the 
  media will be saved in Google Drive)
- Automatic update of docker images using watchtower

### Requirements:
- VPN account
- Google Drive account

# Folder structure
Important files and folders:
```
plexflix
├── .env                           - Environment configuration (options, servers, etc..)
├── docker-compose.yml             - Main Compose services configuration. Don't change!
├── docker-compose.override.yml    - Compose overrides. Add customizations here
├── config                         - Folder with config and critical data for all services
│   ├── borgmatic         
│   │   ├── config.yml             - Borgmatic backup configuration
│   │   └── crontab.txt            - Schedule for backup
│   ├── rclone            
│   │   ├── rclone.conf            - Configuration for rclone's remotes
│   │   └── excludes               - List of files that should not be uploaded to Google Drive
│   ├── plex
│   ├── sonarr            
│   ├── radarr            
│   └── ...               
├── data                  
│   ├── gmedia                     - This is where your media will be mounted from GDrive
│   ├── backups                    - Folder that store the daily backups
│   ├── downloads                  - Used by transmission for downloads
│   └── ...               
└── logs                           - Logs for most apps
```

# Setup

## Install required software
1. Create a user, preferable with uid=1000/gid=1000 (if not, change these values in 
   the `.env` file)
2. Login with the newly created user
3. Install Docker:
    ```
    sudo curl -L https://get.docker.com | bash
    sudo usermod -aG docker $USER
    ```
4. Install Docker Compose (requires Python):
    ```
    pip install docker-compose
    ```
5. Clone this repo:
    ```
    git clone https://github.com/corintio/plexflix
    cd plexflix
    ```

NOTE: All steps and examples bellow assume you are in the project folder.

That's all you need to install. All required software (i.e. Plex, Sonarr, etc..) will be 
download and installed by Docker. But before starting all apps, **you must complete the 
initial configuration**.


## Initial Configuration
1. Create a `.env` file with your configuration (see `.env.sample`)
2. Create a copy of `./defaults` folder called `./config`

You can change some Docker configurations (ex: volume paths) by creating a 
`docker-compose.override.yml`. See [Docker Compose documentation](https://docs.docker.com/compose/extends/#adding-and-overriding-configuration) for details 

If you don't want or need one of the service in this project, say transmission for 
example, just add the following in your override file:
```
version: '3.7'
services:
   transmission:
     entrypoint: ["echo", "Service disabled"]
     restart: "no"
```

## Caddy
```
htpasswd -B -C 15 -c ./config/caddy/.htpasswd username
echo "your.domain.com" > ./config/caddy/redirect_hosts.txt
```

## Rclone
Create a configuration for Rclone in the `./config/rclone` folder. You need to create a 
configuration for your remote Goggle Drive with the `gcrypt:` name. If you want a 
different name, set the `REMOTE_PATH` env var in `.env` with the new value

Make sure Rclone is starting and mounting your remote correctly. To test it, run 
`docker-compose up --build rclone` and check for any errors. Go to a different terminal 
and try to access the mountpoint (default: `./data/gmedia`), check if your files are 
there.


## Plex
Start Plex with `docker-compose up plex`, go to http://your_ip:32400/web and follow the 
instructions. If you are installing in a remote server (different network), please follow
[these instructions](https://support.plex.tv/articles/200288586-installation/#toc-2) 
(see "On a Different Network" section).

After Plex is up and running, change the Transcoding path to `/transcode`, so it uses a 
RAM disk to do the transcoding, which is much faster and less of a toll to your HDD/SDD

## Transmission + VPN
See https://github.com/haugene/docker-transmission-openvpn for details on how to
configure the VPN access. If you are using a custom VPN, copy your VPN Config 
to `/config/vpn`

## Borgmatic (backup)
Before borgmatic can do its magic, you need to create a new borg repository. Make sure 
to set your password in `/config/borgmatic/config.yml` first

To simplify access to your backups, create the following aliases in our `.bashrc`:
```
alias borgmatic='docker-compose run --rm  borgmatic borgmatic'
alias borg='docker-compose run --rm borgmatic borg'
```

Command to initialize a new repo:
```
borgmatic --init --encryption repokey-blake2
```

## Other apps

### Initial BasePath configuration
Some of the applications in this project need to be configured before being able to be 
properly proxied (ex: add base path). To be able to do these configurations, create a 
`docker-compose.override.yml` exposing the ports for the app. 

Example: Jackett
```
---
version: '3.7'
services:
  jackett:
    ports:
    - 9117:9117
```

After starting the app container, you should be able to go to 
http://your.domain.com:9117 and configure Jackett to the correct base path `/jackett`

Apps that require this workaround, and their respective ports that need to be open:
- Jackett: 9117
- Ombi: 3579

Remember to remove this override after the app is properly configured, as the ports will 
be exposed to external access

# To Do
- Fix Rclone logging
- CronJobs: https://hub.docker.com/r/willfarrell/crontab?
  - Auto clean .trash (remove older than 1 month)
  - Docker-GC: https://github.com/spotify/docker-gc
  - Log rotate https://hub.docker.com/r/blacklabelops/logrotate
  - Call watchtower(?)
- Replace Basic Auth with Google Authentication oAuth (https://caddyserver.com/docs/http.login)
  Maybe installing Caddy with params? `CADDY_TELEMETRY=on curl https://getcaddy.com | bash -s personal http.cache,http.cgi,http.jwt,http.login,http.realip,tls.dns.cloudflare`
- Finish Ansible setup
- Investigate use of hardlinks and moves in Sonarr/Radarr

# Future
- Move Rclone to own project and publish the image in Docker Hub
- Automate full restore
- Auto convert magnet links to .torrent files in the watch folder
- Calibre https://hub.docker.com/r/linuxserver/calibre-web/
- Cockpit https://cockpit-project.org/
- Investigate qBittorrent+SOCKS5
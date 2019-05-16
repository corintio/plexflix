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
- Caddy - https://github.com/lucaslorentz/caddy-docker-proxy
- Rclone - (see folder `rclone-gdrive`)
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

```
.
├── .env                           - Environment configuration (options, servers, etc..)
├── docker-compose.yml             - Main Compose services configuration. Don't change!
├── docker-compose.override.yml    - Compose overrides. Add customizations here
├── config                         - Folder with config and critical data for all services
│   ├── borgmatic         
│   │   ├── config.yml             - Borgmatic backup configuration
│   │   └── crontab.txt            - Schedule for backup
│   ├── rclone            
│   │   └── .rclone.conf           - Configuration for rclone's remotes
│   ├── plex
│   ├── sonarr            
│   ├── radarr            
│   ├── ...               
├── data                  
│   ├── gmedia                     - This is where your media will be mounted from GDrive
│   ├── backups                    - Folder that store the daily backups
│   ├── downloads                  - Used by transmission for downloads
│   ├── ...               
└── logs                           - Logs for most apps
```

# Setup

## Install required software
1. Create a user, preferable with uid=1000/gid=1000 (if not, change these values in 
   the `.env` file)
2. Login with the newly created user
3. Install Docker
    ```
    sudo curl -L https://get.docker.com | bash
    sudo usermod -aG docker $USER
    ```
4. Install Docker Compose
    ```
    pip install docker-compose
    ```


## Initial Configuration
- Create a `.env` file with your configuration (see `.env.sample`)
- Create a copy of `defaults` folder called `config`
- Create borgmatic configurations in `config/borgmatic/config.yml` (see the samples)

## Plex
To be able to configure plex for the first time, add the following to the 
`docker-compose.override.yml`:
```
---
version: '3.7'
services:
  plex:
    network_mode: host
```
Remove this override after the plex server is properly configured and claimed, or else 
the other apps won't be able to communicate with it

## Transmission + VPN
See https://github.com/haugene/docker-transmission-openvpn for details on how to
configure the VPN access. If you are using a custom VPN, copy your VPN Config 
to `/config/vpn`

## Borgmatic (backup)
Before borgmatic can do its magic, you need to create a new borg repository. Make sure 
to set your password in `/config/borgmatic/config.yml` first (see "Configure your 
environment" above)

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
Most applications need to be configured before being able to be properly proxied (ex: 
add base path). To be able to do it, create a `docker-compose.override.yml` exposing the 
ports for the app. Ex:
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
- Sonarr: 8989
- Radarr: 7878
- Tautulli: 8181
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
- Remove http authentication from Radarr/Sonarr API

# Future
- Move Rclone to own project and publish the image in Docker Hub
- Automate full restore
- Auto convert magnet links to .torrent files in the watch folder
- Calibre https://hub.docker.com/r/linuxserver/calibre-web/
- Cockpit https://cockpit-project.org/
- Investigate qBittorrent+SOCKS5
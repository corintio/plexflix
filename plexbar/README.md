PlexBar
=======

This is a plugin for [BitBar](https://getbitbar.com/). It allows you to keep an eye on your services:


![Screenshot](https://res.cloudinary.com/dmmwyzcym/image/upload/v1572967589/Screen_Shot_2019-11-03_at_23.54.31_a5tv3a.png)


Configure your servers in `~/.plexbar.yml`. Sample config:
```
tautulli:
  url: https://server.mydomain.com/tautulli
  apikey: 5af0de9cf6f3befb43cb764174a952cd

sonarr:
  url: https://server.mydomain.com/sonarr
  apikey: 7b99cb6242d0ece3a21dd661473a85dc

radarr:
  url: https://server.mydomain.com/radarr
  apikey: 9e6f41fbb004e144ec9a0e69b0f0b011

transmission:
  url: https://server.mydomain.com/transmission
  user: user
  password: password
```
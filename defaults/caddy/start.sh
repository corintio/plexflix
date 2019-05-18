#!/bin/sh

if [ ! -x /data/caddy ]; then
    echo "Caddy not installed, downloading..."
    apk add -U --no-cache ca-certificates bash gnupg

    PLUGINS=http.cache,http.cgi,http.jwt,http.login,http.realip,tls.dns.cloudflare,docker
    CADDY_TELEMETRY=on wget -O- https://getcaddy.com | bash -s personal ${PLUGINS}
    mkdir -p /data
    cp /usr/local/bin/caddy /data
    cp /etc/ssl/certs/ca-certificates.crt /data
else 
    cp /data/caddy /usr/local/bin
    cp /data/ca-certificates.crt /etc/ssl/certs
    echo "Found `/usr/local/bin/caddy --version`"
fi
exec /usr/local/bin/caddy $@
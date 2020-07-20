FROM alpine as builder

RUN apk add -U --no-cache ca-certificates bash gnupg
# RUN CADDY_TELEMETRY=on wget -O- https://getcaddy.com | bash -s personal  \
#     http.cache,http.cgi,http.jwt,http.login,http.realip,tls.dns.cloudflare,docker

FROM scratch
EXPOSE 80 443 2015
ENV HOME /root

WORKDIR /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=builder /usr/local/bin/caddy /bin/
COPY caddy /bin/

ENTRYPOINT ["/bin/caddy"]
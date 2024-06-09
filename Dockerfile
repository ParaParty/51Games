FROM caddy:latest

COPY Caddyfile /etc/caddy/Caddyfile

COPY . /srv

EXPOSE 80

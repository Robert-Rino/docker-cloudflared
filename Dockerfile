FROM cloudflare/cloudflared:2022.7.1

ENTRYPOINT ["cloudflared", "tunnel", "run"]

# Dockerfile for a custom Traefik image
# Author: Recep GUCLUER
FROM traefik:v2.11.0

# Static Configuration
COPY traefik.yml /etc/traefik/traefik.yml

# Dynamic Configuration
COPY dynamic.yml /etc/traefik/dynamic.yml

# Hetzner API key
# TODO: Find a more secure way
COPY hetzner_api_key.txt /etc/traefik/hetzner_api_key.txt

# Users
COPY users.txt /etc/traefik/users.txt

# Storage
COPY ./storage/. /traefik/storage/

EXPOSE 80
EXPOSE 443
EXPOSE 8080
EXPOSE 8082


# Dockerfile for a custom Traefik image
# Author: Recep GUCLUER
FROM traefik:v3.1.2

# Install lego
RUN apk update && apk add --no-cache lego

# Static Configuration
COPY traefik.yml /etc/traefik/traefik.yml

# Dynamic Configuration
COPY dynamic.yml /etc/traefik/dynamic.yml

# Copy your DNS auth service provider keys
# Uncomment the following row and modify according to your setup
# COPY your_file_api_key.txt /etc/traefik/your_file_api_key.txt

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


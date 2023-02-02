# Dockerfile for a basic Nginx image
# Author: Recep GUCLUER
FROM nginx:1.23

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/ /etc/nginx/conf.d
COPY data/www/ /usr/share/nginx/html
COPY data/images/ /usr/share/nginx/html/images

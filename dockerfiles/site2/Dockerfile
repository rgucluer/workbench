# Dockerfile for a basic Nginx image
# Author: Recep GUCLUER
FROM nginx:1.23

ARG virtual_host="site2.local"

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/ /etc/nginx/conf.d
RUN sed -i "s/site2.local/${virtual_host}/g" /etc/nginx/conf.d/site2.conf
COPY data/www/ /usr/share/nginx/html
COPY data/images/ /usr/share/nginx/images

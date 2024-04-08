# Dockerfile for a basic Nginx image
# Author: Recep GUCLUER
FROM nginx:1.25.3

ARG virtual_host="app2.local"

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/ /etc/nginx/conf.d
RUN sed -i "s/app2.local/${virtual_host}/g" /etc/nginx/conf.d/app2.conf
COPY data/www/ /usr/share/nginx/html
COPY data/images/ /usr/share/nginx/images

EXPOSE 80
EXPOSE 443